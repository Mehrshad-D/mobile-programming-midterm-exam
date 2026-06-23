import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const String _encryptionKeyName = 'aes_encryption_key';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<String?> readEncryptionKey() async {
    return _storage.read(key: _encryptionKeyName);
  }

  Future<void> writeEncryptionKey(String key) async {
    await _storage.write(key: _encryptionKeyName, value: key);
  }

  Future<void> deleteEncryptionKey() async {
    await _storage.delete(key: _encryptionKeyName);
  }
}
