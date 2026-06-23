import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

import 'secure_storage_service.dart';

class EncryptionException implements Exception {
  final String message;
  EncryptionException(this.message);

  @override
  String toString() => message;
}

class EncryptionService {
  EncryptionService(this._secureStorage);

  final SecureStorageService _secureStorage;
  Key? _key;
  final IV _iv = IV.fromLength(16);

  Future<void> initialize() async {
    var keyString = await _secureStorage.readEncryptionKey();
    if (keyString == null || keyString.isEmpty) {
      keyString = _generateKey();
      await _secureStorage.writeEncryptionKey(keyString);
    }
    _key = Key.fromBase64(keyString);
  }

  Future<void> resetKey() async {
    final newKey = _generateKey();
    await _secureStorage.writeEncryptionKey(newKey);
    _key = Key.fromBase64(newKey);
  }

  String _generateKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  Encrypter get _encrypter {
    final key = _key;
    if (key == null) {
      throw EncryptionException('Encryption key is not initialized.');
    }
    return Encrypter(AES(key));
  }

  String encrypt(String plainText) {
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (_) {
      throw EncryptionException('Failed to encrypt data.');
    }
  }

  String decrypt(String encryptedText) {
    try {
      final encrypted = Encrypted.fromBase64(encryptedText);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (_) {
      throw EncryptionException('Failed to decrypt data.');
    }
  }

  String hashForSearch(String value) {
    return sha256.convert(utf8.encode(value)).toString();
  }
}
