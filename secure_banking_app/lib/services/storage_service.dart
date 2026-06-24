import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  static const String _tokenKey = 'auth_token';

  // Android: uses EncryptedSharedPreferences + Keystore (configured in Gradle minSdk 23+)
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> readToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<bool> isSecureStorageAvailable() async {
    try {
      const probeKey = '__secure_storage_probe__';
      await _storage.write(key: probeKey, value: 'ok');
      final value = await _storage.read(key: probeKey);
      await _storage.delete(key: probeKey);
      return value == 'ok';
    } catch (_) {
      return false;
    }
  }
}
