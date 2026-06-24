class SecurityReport {
  const SecurityReport({
    required this.rootDetected,
    required this.emulatorDetected,
    required this.debugDetected,
    required this.environmentSafe,
    required this.signatureValid,
    required this.tampered,
    required this.biometricEnabled,
    required this.secureStorageEnabled,
    required this.screenshotBlockingEnabled,
    this.appSignature,
  });

  final bool rootDetected;
  final bool emulatorDetected;
  final bool debugDetected;
  final bool environmentSafe;
  final bool signatureValid;
  final bool tampered;
  final bool biometricEnabled;
  final bool secureStorageEnabled;
  final bool screenshotBlockingEnabled;
  final String? appSignature;

  SecurityReport copyWith({
    bool? biometricEnabled,
    bool? secureStorageEnabled,
    bool? screenshotBlockingEnabled,
  }) {
    return SecurityReport(
      rootDetected: rootDetected,
      emulatorDetected: emulatorDetected,
      debugDetected: debugDetected,
      environmentSafe: environmentSafe,
      signatureValid: signatureValid,
      tampered: tampered,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      secureStorageEnabled: secureStorageEnabled ?? this.secureStorageEnabled,
      screenshotBlockingEnabled:
          screenshotBlockingEnabled ?? this.screenshotBlockingEnabled,
      appSignature: appSignature,
    );
  }
}
