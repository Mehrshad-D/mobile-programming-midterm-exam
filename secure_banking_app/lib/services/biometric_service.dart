import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthResult {
  const BiometricAuthResult({
    required this.success,
    this.errorMessage,
    this.deviceSupported = false,
    this.canCheckBiometrics = false,
  });

  final bool success;
  final String? errorMessage;
  final bool deviceSupported;
  final bool canCheckBiometrics;
}

class BiometricService {
  BiometricService._();

  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<BiometricAuthResult> authenticate() async {
    try {
      final deviceSupported = await _auth.isDeviceSupported();
      final canCheckBiometrics = await _auth.canCheckBiometrics;

      if (!deviceSupported) {
        return BiometricAuthResult(
          success: false,
          deviceSupported: false,
          canCheckBiometrics: canCheckBiometrics,
          errorMessage:
              'No screen lock is set on this device. Set a PIN in Android Settings first.',
        );
      }

      final success = await _auth.authenticate(
        localizedReason: 'Authenticate to access your secure banking account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );

      return BiometricAuthResult(
        success: success,
        deviceSupported: deviceSupported,
        canCheckBiometrics: canCheckBiometrics,
        errorMessage: success ? null : 'Authentication was cancelled or failed.',
      );
    } on PlatformException catch (e) {
      return BiometricAuthResult(
        success: false,
        errorMessage: e.message ?? 'Biometric authentication error.',
      );
    } catch (e) {
      return BiometricAuthResult(
        success: false,
        errorMessage: 'Authentication error: $e',
      );
    }
  }
}
