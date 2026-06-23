import 'dart:async';
import 'dart:convert';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

class NfcScanResult {
  final String tagId;
  final String technology;
  final String payload;

  const NfcScanResult({
    required this.tagId,
    required this.technology,
    required this.payload,
  });
}

class NfcService {
  NfcService(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<bool> isAvailable() async {
    try {
      return await NfcManager.instance.isAvailable();
    } catch (_) {
      return false;
    }
  }

  Future<NfcScanResult?> startScan({
    required void Function(String status) onStatus,
  }) async {
    final available = await isAvailable();
    if (!available) return null;

    final completer = Completer<NfcScanResult?>();

    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          onStatus('Tag discovered');
          final result = _parseTag(tag);
          await NfcManager.instance.stopSession();
          if (!completer.isCompleted) {
            completer.complete(result);
          }
        },
        onError: (error) async {
          onStatus('Scan error');
          await NfcManager.instance.stopSession(errorMessage: error.message);
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
      );

      return await completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () async {
          await stopSession();
          return null;
        },
      );
    } catch (_) {
      await stopSession();
      return null;
    }
  }

  Future<void> stopSession() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {}
  }

  NfcScanResult _parseTag(NfcTag tag) {
    final data = tag.data;
    final idBytes = data['nfca']?['identifier'] ??
        data['nfcb']?['identifier'] ??
        data['nfcf']?['identifier'] ??
        data['nfcv']?['identifier'] ??
        <int>[];

    final tagId = idBytes is List
        ? idBytes
            .map((e) => (e as int).toRadixString(16).padLeft(2, '0'))
            .join(':')
            .toUpperCase()
        : 'Unknown';

    final technologies = <String>[];
    if (data.containsKey('nfca')) technologies.add('NFC-A');
    if (data.containsKey('nfcb')) technologies.add('NFC-B');
    if (data.containsKey('nfcf')) technologies.add('NFC-F');
    if (data.containsKey('nfcv')) technologies.add('NFC-V');
    if (data.containsKey('isodep')) technologies.add('ISO-DEP');
    if (data.containsKey('mifareultralight')) {
      technologies.add('Mifare Ultralight');
    }
    if (data.containsKey('mifareclassic')) technologies.add('Mifare Classic');
    if (data.containsKey('ndef')) technologies.add('NDEF');

    var payload = 'No readable payload';
    final ndef = data['ndef'];
    if (ndef != null && ndef is Map) {
      final cached = ndef['cachedMessage'];
      if (cached != null && cached is Map) {
        final records = cached['records'];
        if (records is List && records.isNotEmpty) {
          final payloads = <String>[];
          for (final record in records) {
            if (record is Map) {
              final payloadBytes = record['payload'];
              if (payloadBytes is List) {
                try {
                  payloads.add(utf8.decode(
                    List<int>.from(payloadBytes),
                    allowMalformed: true,
                  ));
                } catch (_) {
                  payloads.add(payloadBytes.toString());
                }
              }
            }
          }
          if (payloads.isNotEmpty) {
            payload = payloads.join('\n');
          }
        }
      }
    }

    return NfcScanResult(
      tagId: tagId,
      technology: technologies.isEmpty ? 'Unknown' : technologies.join(', '),
      payload: payload,
    );
  }

  Future<String?> getNote(String tagId) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      DatabaseHelper.nfcNotesTable,
      where: 'tagId = ?',
      whereArgs: [tagId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['note'] as String?;
  }

  Future<void> saveNote(String tagId, String note) async {
    final db = await _databaseHelper.database;
    await db.insert(
      DatabaseHelper.nfcNotesTable,
      {
        'tagId': tagId,
        'note': note,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
