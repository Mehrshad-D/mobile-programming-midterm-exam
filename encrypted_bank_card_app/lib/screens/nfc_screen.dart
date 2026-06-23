import 'package:flutter/material.dart';

import '../services/app_services.dart';

class NfcScreen extends StatefulWidget {
  const NfcScreen({super.key});

  @override
  State<NfcScreen> createState() => _NfcScreenState();
}

class _NfcScreenState extends State<NfcScreen> {
  bool _isAvailable = false;
  bool _isChecking = true;
  bool _isScanning = false;
  String _status = '';
  String? _tagId;
  String? _technology;
  String? _payload;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  @override
  void dispose() {
    _noteController.dispose();
    AppServices.instance.nfcService.stopSession();
    super.dispose();
  }

  Future<void> _checkAvailability() async {
    final available = await AppServices.instance.nfcService.isAvailable();
    if (mounted) {
      setState(() {
        _isAvailable = available;
        _isChecking = false;
      });
    }
  }

  Future<void> _startScan() async {
    if (!_isAvailable || _isScanning) return;

    setState(() {
      _isScanning = true;
      _status = 'Hold your device near an NFC tag...';
      _tagId = null;
      _technology = null;
      _payload = null;
      _noteController.clear();
    });

    try {
      final result = await AppServices.instance.nfcService.startScan(
        onStatus: (status) {
          if (mounted) setState(() => _status = status);
        },
      );

      if (!mounted) return;

      if (result != null) {
        final note =
            await AppServices.instance.nfcService.getNote(result.tagId);
        setState(() {
          _tagId = result.tagId;
          _technology = result.technology;
          _payload = result.payload;
          _status = 'Tag read successfully';
          _noteController.text = note ?? '';
        });
      } else {
        setState(() => _status = 'No tag detected. Try again.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _status = 'Scan failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _saveNote() async {
    if (_tagId == null) return;
    try {
      await AppServices.instance.nfcService.saveNote(
        _tagId!,
        _noteController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note saved')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save note')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NFC Scanner')),
      body: _isChecking
          ? const Center(child: CircularProgressIndicator())
          : !_isAvailable
              ? _buildUnavailable()
              : _buildScanner(),
    );
  }

  Widget _buildUnavailable() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.nfc, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            const Text(
              'NFC is not available on this device.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Text(
              'NFC scanning requires a device with NFC hardware enabled.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanner() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.nfc,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  _status.isEmpty ? 'Ready to scan' : _status,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isScanning ? null : _startScan,
                    icon: _isScanning
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.sensors),
                    label: Text(_isScanning ? 'Scanning...' : 'Start Scan'),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_tagId != null) ...[
          const SizedBox(height: 20),
          _infoCard('Tag ID', _tagId!),
          const SizedBox(height: 12),
          _infoCard('Technology', _technology ?? 'Unknown'),
          const SizedBox(height: 12),
          _infoCard('Payload', _payload ?? 'Empty'),
          const SizedBox(height: 20),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Note for this tag',
              hintText: 'Add a small note...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveNote,
              icon: const Icon(Icons.save),
              label: const Text('Save Note'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _infoCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            SelectableText(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
