import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/biometric_service.dart';
import '../services/security_service.dart';
import 'home_screen.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  bool _isAuthenticating = false;
  String? _errorMessage;
  bool _isEmulator = false;
  bool _deviceSupported = true;

  @override
  void initState() {
    super.initState();
    _isEmulator =
        SecurityService.instance.report?.emulatorDetected ?? false;
    _loadDeviceStatus();
  }

  Future<void> _loadDeviceStatus() async {
    final supported = await BiometricService.instance.isDeviceSupported();
    if (!mounted) {
      return;
    }
    setState(() => _deviceSupported = supported);
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    BiometricAuthResult result;
    try {
      result = await BiometricService.instance
          .authenticate()
          .timeout(const Duration(seconds: 60));
    } catch (_) {
      result = const BiometricAuthResult(
        success: false,
        errorMessage: 'Authentication timed out. Please try again.',
      );
    }

    if (!mounted) {
      return;
    }

    if (result.success) {
      _goToHome();
      return;
    }

    setState(() {
      _isAuthenticating = false;
      _deviceSupported = result.deviceSupported;
      _errorMessage = result.errorMessage ??
          'Authentication failed. Tap the button below and use PIN or fingerprint.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fingerprint_rounded,
                    size: 56,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Biometric Authentication',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                kIsWeb
                    ? 'Biometrics are not available in the browser.'
                    : 'Authenticate with the emulator/device fingerprint or device PIN.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              if (_isEmulator && !kIsWeb) ...[
                const SizedBox(height: 20),
                _InstructionCard(
                  title: 'Emulator setup (does not use laptop fingerprint)',
                  steps: const [
                    'Open Android Settings → Security → Screen lock → set a PIN (e.g. 1234).',
                    'In the emulator toolbar, open Extended Controls (⋯) → Fingerprint.',
                    'Add a fingerprint, then click "Touch the sensor" to simulate it.',
                    'Return here and tap Authenticate — use simulated fingerprint or PIN.',
                  ],
                  colorScheme: colorScheme,
                ),
              ],
              if (!_deviceSupported && !kIsWeb) ...[
                const SizedBox(height: 16),
                _InstructionCard(
                  title: 'Screen lock required',
                  steps: const [
                    'This device has no PIN/pattern/password configured.',
                    'Set one in Android Settings → Security → Screen lock, then retry.',
                  ],
                  colorScheme: colorScheme,
                  isWarning: true,
                ),
              ],
              const SizedBox(height: 28),
              if (kIsWeb)
                FilledButton.icon(
                  onPressed: _goToHome,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Continue to Home'),
                )
              else ...[
                FilledButton.icon(
                  onPressed: _isAuthenticating ? null : _authenticate,
                  icon: const Icon(Icons.fingerprint_rounded),
                  label: Text(
                    _isAuthenticating
                        ? 'Waiting for authentication...'
                        : 'Authenticate (Fingerprint or PIN)',
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                if (_isEmulator) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _isAuthenticating ? null : _goToHome,
                    icon: const Icon(Icons.skip_next_rounded),
                    label: const Text('Skip for Emulator Demo'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Educational bypass — only shown on emulator.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              if (_isAuthenticating) ...[
                const SizedBox(height: 20),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({
    required this.title,
    required this.steps,
    required this.colorScheme,
    this.isWarning = false,
  });

  final String title;
  final List<String> steps;
  final ColorScheme colorScheme;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: isWarning
          ? colorScheme.errorContainer.withValues(alpha: 0.35)
          : colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isWarning
              ? colorScheme.error.withValues(alpha: 0.3)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isWarning ? Icons.info_outline : Icons.phone_android_rounded,
                  color: isWarning ? colorScheme.error : colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...steps.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key + 1}. ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
