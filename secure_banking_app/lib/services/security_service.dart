import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/security_report.dart';
import '../utils/platform_helper.dart';
import 'biometric_service.dart';
import 'signature_service.dart';
import 'storage_service.dart';

class SecurityService {
  SecurityService._();

  static final SecurityService instance = SecurityService._();

  static const MethodChannel _channel =
      MethodChannel('com.example.secure_banking_app/security');

  SecurityReport? _report;

  SecurityReport? get report => _report;

  Future<SecurityReport> runSecurityChecks() async {
    final rootDetected = await _detectRoot();
    final emulatorDetected = await _detectEmulator();
    final debugDetected = await _detectDebug();

    await SignatureService.instance.verifySignature();

    // Only root blocks app entry. Emulator is reported but allowed.
    final environmentSafe = !rootDetected;

    final biometricEnabled = await _withTimeout(
      BiometricService.instance.isBiometricAvailable(),
      fallback: false,
    );
    final secureStorageEnabled = await _withTimeout(
      StorageService.instance.isSecureStorageAvailable(),
      fallback: false,
    );

    _report = SecurityReport(
      rootDetected: rootDetected,
      emulatorDetected: emulatorDetected,
      debugDetected: debugDetected,
      environmentSafe: environmentSafe,
      signatureValid: SignatureService.instance.signatureValid,
      tampered: SignatureService.instance.tampered,
      biometricEnabled: biometricEnabled,
      secureStorageEnabled: secureStorageEnabled,
      screenshotBlockingEnabled: false,
      appSignature: SignatureService.instance.computedSignature,
    );

    return _report!;
  }

  Future<T> _withTimeout<T>(Future<T> future, {required T fallback}) async {
    try {
      return await future.timeout(const Duration(seconds: 5));
    } catch (_) {
      return fallback;
    }
  }

  Future<bool> _detectRoot() async {
    if (!isAndroid) {
      return false;
    }

    try {
      final rooted = await _channel
          .invokeMethod<bool>('isDeviceRooted')
          .timeout(const Duration(seconds: 3));
      return rooted ?? false;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _detectEmulator() async {
    if (kIsWeb) {
      return true;
    }

    final deviceInfo = DeviceInfoPlugin();

    if (isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      if (!androidInfo.isPhysicalDevice) {
        return true;
      }

      final fingerprint = androidInfo.fingerprint.toLowerCase();
      final model = androidInfo.model.toLowerCase();
      final product = androidInfo.product.toLowerCase();
      final brand = androidInfo.brand.toLowerCase();

      if (fingerprint.contains('generic') ||
          fingerprint.contains('emulator') ||
          model.contains('emulator') ||
          model.contains('sdk') ||
          product.contains('sdk') ||
          brand.contains('generic')) {
        return true;
      }
    } else if (isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      if (!iosInfo.isPhysicalDevice) {
        return true;
      }
    }

    return false;
  }

  Future<bool> _detectDebug() async {
    if (kDebugMode) {
      return true;
    }

    if (isAndroid) {
      try {
        final debuggerAttached = await _channel
            .invokeMethod<bool>('isDebuggerAttached')
            .timeout(const Duration(seconds: 3));
        if (debuggerAttached == true) {
          return true;
        }
      } on PlatformException {
        // Fall through on unsupported platforms.
      } catch (_) {
        return false;
      }
    }

    return false;
  }

  void updateScreenshotBlockingStatus(bool enabled) {
    if (_report != null) {
      _report = _report!.copyWith(screenshotBlockingEnabled: enabled);
    }
  }
}
