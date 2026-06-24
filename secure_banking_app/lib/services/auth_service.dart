import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'storage_service.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  String generateFakeJwt(String phoneNumber) {
    final header = base64Url.encode(
      utf8.encode('{"alg":"HS256","typ":"JWT"}'),
    );
    final payload = base64Url.encode(
      utf8.encode(
        '{"sub":"$phoneNumber","name":"Demo User","iat":${DateTime.now().millisecondsSinceEpoch ~/ 1000},"exp":${DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch ~/ 1000}}',
      ),
    );
    final signatureBytes = sha256.convert(
      utf8.encode('$header.$payload.secure_banking_demo_secret'),
    );
    final signature = base64Url.encode(signatureBytes.bytes);
    return '$header.$payload.$signature';
  }

  Future<void> storeSession(String phoneNumber) async {
    final token = generateFakeJwt(phoneNumber);
    await StorageService.instance.saveToken(token);
  }

  Future<bool> hasValidSession() async {
    final token = await StorageService.instance.readToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await StorageService.instance.deleteToken();
  }
}
