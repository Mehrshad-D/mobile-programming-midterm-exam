import 'package:flutter/material.dart';
import 'package:sensor_dashboard_live_wallpaper/services/permission_service.dart';
import 'package:sensor_dashboard_live_wallpaper/services/sensor_service.dart';
import 'package:sensor_dashboard_live_wallpaper/widgets/live_background.dart';

class StepCounterScreen extends StatefulWidget {
  const StepCounterScreen({super.key});

  @override
  State<StepCounterScreen> createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen> {
  bool _permissionChecked = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    await PermissionService.instance.ensureActivityRecognitionPermission();
    if (mounted) setState(() => _permissionChecked = true);
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
            title: const Text('Step Counter'),
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
              child: !_permissionChecked
                  ? const Center(child: CircularProgressIndicator())
                  : service.pedometerAvailable
                      ? _StepsView(steps: service.steps)
                      : _UnavailableView(message: service.pedometerMessage),
            ),
          ),
        );
      },
    );
  }
}

class _StepsView extends StatelessWidget {
  const _StepsView({required this.steps});

  final int steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Icon(
                Icons.directions_walk,
                size: 72,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Steps Today',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$steps',
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Live updates enabled',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
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
              Icons.directions_walk,
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
