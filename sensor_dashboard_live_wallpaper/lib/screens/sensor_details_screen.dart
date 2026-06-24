import 'package:flutter/material.dart';
import 'package:sensor_dashboard_live_wallpaper/models/sensor_info.dart';
import 'package:sensor_dashboard_live_wallpaper/services/sensor_service.dart';
import 'package:sensor_dashboard_live_wallpaper/widgets/live_background.dart';

class SensorDetailsScreen extends StatelessWidget {
  const SensorDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SensorService.instance,
      builder: (context, _) {
        final sensors = SensorService.instance.allSensors;
        final theme = Theme.of(context);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text('Sensor Details'),
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
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sensors.length,
                itemBuilder: (context, index) {
                  return _SensorDetailTile(sensor: sensors[index]);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SensorDetailTile extends StatelessWidget {
  const _SensorDetailTile({required this.sensor});

  final SensorInfo sensor;

  IconData _statusIcon() {
    switch (sensor.status) {
      case SensorStatus.available:
        return Icons.check_circle;
      case SensorStatus.unavailable:
        return Icons.cancel;
      case SensorStatus.permissionDenied:
        return Icons.lock;
      case SensorStatus.error:
        return Icons.error;
    }
  }

  Color _statusColor(BuildContext context) {
    switch (sensor.status) {
      case SensorStatus.available:
        return Colors.green;
      case SensorStatus.unavailable:
        return Theme.of(context).colorScheme.error;
      case SensorStatus.permissionDenied:
        return Colors.orange;
      case SensorStatus.error:
        return Theme.of(context).colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    sensor.icon,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sensor.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  _statusIcon(),
                  color: _statusColor(context),
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              sensor.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Divider(height: 24),
            _DetailRow(label: 'Current Value', value: sensor.value),
            _DetailRow(label: 'Update Frequency', value: sensor.updateFrequency),
            _DetailRow(
              label: 'Availability',
              value: sensor.isAvailable ? 'Available' : sensor.statusMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
