import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricResult {
  final bool success;
  final String? message;

  const BiometricResult({required this.success, this.message});
}

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  Future<BiometricResult> authenticate() async {
    try {
      final supported = await isDeviceSupported();
      if (!supported) {
        return const BiometricResult(
          success: false,
          message: 'Biometric authentication is not available on this device.',
        );
      }

      final authenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to access your bank cards',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        return const BiometricResult(success: true);
      }
      return const BiometricResult(
        success: false,
        message: 'Authentication failed. Please try again.',
      );
    } on PlatformException catch (e) {
      return BiometricResult(
        success: false,
        message: e.message ?? 'Authentication error occurred.',
      );
    } catch (_) {
      return const BiometricResult(
        success: false,
        message: 'An unexpected error occurred during authentication.',
      );
    }
  }
}
