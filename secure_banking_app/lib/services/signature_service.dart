import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../utils/platform_helper.dart';

class SignatureService {
  SignatureService._();

  static final SignatureService instance = SignatureService._();

  static const MethodChannel _channel =
      MethodChannel('com.example.secure_banking_app/security');

  /// Expected SHA-256 of the signing certificate for release builds.
  /// Copy the hash from Security Report after a release-signed build.
  static const String expectedSignatureSha256 =
      'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';

  String? _computedSignature;
  bool _signatureValid = false;
  bool _tampered = false;
  bool _validatedInDebugMode = false;

  String? get computedSignature => _computedSignature;
  bool get signatureValid => _signatureValid;
  bool get tampered => _tampered;
  bool get validatedInDebugMode => _validatedInDebugMode;

  Future<void> verifySignature() async {
    _validatedInDebugMode = false;

    if (kIsWeb) {
      _computedSignature = 'web_platform';
      _signatureValid = true;
      _tampered = false;
      return;
    }

    if (!isAndroid) {
      _computedSignature = 'unsupported_platform';
      _signatureValid = true;
      _tampered = false;
      return;
    }

    try {
      final signature = await _channel
          .invokeMethod<String>('getAppSignatureSha256')
          .timeout(const Duration(seconds: 3));
      _computedSignature = signature ?? '';

      if (_computedSignature!.isEmpty) {
        _signatureValid = false;
        _tampered = true;
        return;
      }

      final matchesRelease = _computedSignature == expectedSignatureSha256;

      if (matchesRelease) {
        _signatureValid = true;
        _tampered = false;
        return;
      }

      // Debug builds use the local debug keystore — accept retrieved hash in debug.
      if (kDebugMode) {
        _validatedInDebugMode = true;
        _signatureValid = true;
        _tampered = false;
        return;
      }

      _signatureValid = false;
      _tampered = true;
    } on PlatformException {
      _computedSignature = null;
      _signatureValid = false;
      _tampered = true;
    } catch (_) {
      _computedSignature = null;
      _signatureValid = false;
      _tampered = true;
    }
  }
}
