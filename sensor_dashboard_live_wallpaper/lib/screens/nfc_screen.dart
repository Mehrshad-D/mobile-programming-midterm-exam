import 'package:flutter/material.dart';
import 'package:sensor_dashboard_live_wallpaper/services/sensor_service.dart';
import 'package:sensor_dashboard_live_wallpaper/widgets/live_background.dart';

class NfcScreen extends StatefulWidget {
  const NfcScreen({super.key});

  @override
  State<NfcScreen> createState() => _NfcScreenState();
}

class _NfcScreenState extends State<NfcScreen> {
  @override
  void initState() {
    super.initState();
    SensorService.instance.refreshNfcAvailability();
  }

  @override
  void dispose() {
    SensorService.instance.stopNfcScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SensorService.instance,
      builder: (context, _) {
        final service = SensorService.instance;
        final theme = Theme.of(context);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text('NFC Reader'),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
              ),
            ),
          ),
          body: LiveBackground(
            child: SafeArea(
              child: service.nfcAvailable
                  ? _NfcContent(service: service)
                  : _UnavailableView(message: service.nfcMessage),
            ),
          ),
        );
      },
    );
  }
}

class _NfcContent extends StatelessWidget {
  const _NfcContent({required this.service});

  final SensorService service;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: service.nfcScanning
                  ? theme.colorScheme.primary.withValues(alpha: 0.2)
                  : theme.colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: service.nfcScanning
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.nfc,
              size: 72,
              color: service.nfcScanning
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          if (service.nfcTagDetected) ...[
            Icon(
              Icons.check_circle,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Tag Detected',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            _InfoCard(label: 'Tag ID', value: service.lastNfcTagId),
            const SizedBox(height: 12),
            _InfoCard(label: 'Technology', value: service.lastNfcTechnology),
            const SizedBox(height: 12),
            _InfoCard(label: 'Payload', value: service.lastNfcPayload),
          ] else
            Text(
              service.nfcScanning
                  ? 'Hold an NFC tag near your device…'
                  : 'Tap Start Scan to read NFC tags',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: service.nfcScanning
                  ? () => service.stopNfcScan()
                  : () => service.startNfcScan(),
              icon: Icon(
                service.nfcScanning ? Icons.stop : Icons.nfc,
              ),
              label: Text(service.nfcScanning ? 'Stop Scan' : 'Start Scan'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnavailableView extends StatelessWidget {
  const _UnavailableView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.nfc,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
