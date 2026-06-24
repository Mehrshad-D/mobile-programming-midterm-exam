import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/security_report.dart';
import '../services/screenshot_service.dart';
import '../services/security_service.dart';
import '../services/signature_service.dart';
import '../widgets/secure_screen_mixin.dart';
import '../widgets/security_status_tile.dart';

class SecurityReportScreen extends StatefulWidget {
  const SecurityReportScreen({super.key});

  @override
  State<SecurityReportScreen> createState() => _SecurityReportScreenState();
}

class _SecurityReportScreenState extends State<SecurityReportScreen>
    with WidgetsBindingObserver, SecureScreenMixin {
  SecurityReport? _report;
  String? _appVersion;

  @override
  void initState() {
    super.initState();
    _report = SecurityService.instance.report;
    _loadAppInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScreenshotService.instance.reapplyIfNeeded();
      if (mounted) {
        setState(() {
          _report = SecurityService.instance.report;
        });
      }
    });
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) {
      return;
    }
    setState(() {
      _appVersion = '${info.appName} v${info.version} (${info.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    final report = _report;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Report'),
      ),
      body: report == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          size: 40,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Device Security Overview',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                report.environmentSafe
                                    ? report.emulatorDetected
                                        ? 'Safe for demo (emulator/browser — see report)'
                                        : 'Environment appears safe'
                                    : 'Root detected — environment blocked',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              if (_appVersion != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _appVersion!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SecurityStatusTile(
                  title: 'Root Detection',
                  isSecure: !report.rootDetected,
                  subtitle: report.rootDetected
                      ? 'Root access detected on device'
                      : 'No root indicators found',
                ),
                const SizedBox(height: 10),
                SecurityStatusTile(
                  title: 'Emulator Detection',
                  isSecure: !report.emulatorDetected,
                  subtitle: report.emulatorDetected
                      ? 'Emulator/browser detected — allowed for demo, shown in report only'
                      : 'Physical device detected',
                ),
                const SizedBox(height: 10),
                SecurityStatusTile(
                  title: 'Debug Detection',
                  isSecure: !report.debugDetected,
                  subtitle: report.debugDetected
                      ? 'Debug mode or debugger detected'
                      : 'No debug indicators',
                ),
                const SizedBox(height: 10),
                SecurityStatusTile(
                  title: 'App Signature',
                  isSecure: report.signatureValid,
                  subtitle: report.signatureValid
                      ? SignatureService.instance.validatedInDebugMode
                          ? 'Debug build — signature verified (release hash differs)'
                          : 'Signature matches expected hash'
                      : 'Signature mismatch — app may be tampered',
                  trailing: report.appSignature != null
                      ? IconButton(
                          tooltip: 'Copy signature hash',
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: report.appSignature!),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Signature hash copied'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 20),
                        )
                      : null,
                ),
                if (report.appSignature != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      report.appSignature!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                SecurityStatusTile(
                  title: 'Tampered',
                  isSecure: !report.tampered,
                  subtitle: report.tampered
                      ? 'Application integrity check failed'
                      : 'Application integrity verified',
                ),
                const SizedBox(height: 10),
                SecurityStatusTile(
                  title: 'Biometric Enabled',
                  isSecure: report.biometricEnabled,
                  subtitle: report.biometricEnabled
                      ? 'Biometric authentication available'
                      : 'Biometrics not available on this device',
                ),
                const SizedBox(height: 10),
                SecurityStatusTile(
                  title: 'Secure Storage Enabled',
                  isSecure: report.secureStorageEnabled,
                  subtitle: report.secureStorageEnabled
                      ? 'flutter_secure_storage is operational'
                      : 'Secure storage unavailable',
                ),
                const SizedBox(height: 10),
                SecurityStatusTile(
                  title: 'Screenshot Blocking Enabled',
                  isSecure: ScreenshotService.instance.isProtectionActive,
                  subtitle: ScreenshotService.instance.isProtectionActive
                      ? 'FLAG_SECURE active on this screen'
                      : 'FLAG_SECURE not active — open OTP, Home, or this screen',
                ),
              ],
            ),
    );
  }
}
