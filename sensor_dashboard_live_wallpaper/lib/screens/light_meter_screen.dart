import 'package:flutter/material.dart';
import 'package:sensor_dashboard_live_wallpaper/services/sensor_service.dart';
import 'package:sensor_dashboard_live_wallpaper/services/theme_service.dart';
import 'package:sensor_dashboard_live_wallpaper/widgets/live_background.dart';

class LightMeterScreen extends StatelessWidget {
  const LightMeterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        SensorService.instance,
        ThemeService.instance,
      ]),
      builder: (context, _) {
        final service = SensorService.instance;
        final themeService = ThemeService.instance;
        final theme = Theme.of(context);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text('Light Meter'),
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
            actions: [
              PopupMenuButton<AppThemeMode>(
                icon: const Icon(Icons.palette),
                tooltip: 'Theme mode',
                onSelected: themeService.setMode,
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: AppThemeMode.light,
                    child: Text('Light Theme'),
                  ),
                  const PopupMenuItem(
                    value: AppThemeMode.dark,
                    child: Text('Dark Theme'),
                  ),
                  const PopupMenuItem(
                    value: AppThemeMode.automatic,
                    child: Text('Automatic (Light Sensor)'),
                  ),
                ],
              ),
            ],
          ),
          body: LiveBackground(
            child: SafeArea(
              child: service.lightAvailable && service.lux != null
                  ? _LightView(lux: service.lux!)
                  : _UnavailableView(message: service.lightMessage),
            ),
          ),
        );
      },
    );
  }
}

class _LightView extends StatelessWidget {
  const _LightView({required this.lux});

  final double lux;

  String _getLightLevel(double lux) {
    if (lux < 10) return 'Very Dark';
    if (lux < 50) return 'Dark';
    if (lux < 200) return 'Dim';
    if (lux < 500) return 'Normal Indoor';
    if (lux < 1000) return 'Bright Indoor';
    if (lux < 10000) return 'Overcast Day';
    return 'Direct Sunlight';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final level = _getLightLevel(lux);
    final isAutoDark = ThemeService.instance.isDarkFromLightSensor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.yellow.withValues(alpha: (lux / 1000).clamp(0.1, 1.0)),
                    Colors.orange.withValues(alpha: 0.3),
                    theme.colorScheme.surface.withValues(alpha: 0.5),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withValues(
                      alpha: (lux / 2000).clamp(0.0, 0.6),
                    ),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                lux > 50 ? Icons.wb_sunny : Icons.nightlight_round,
                size: 80,
                color: lux > 50 ? Colors.amber : Colors.indigo,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              '${lux.toStringAsFixed(0)} lux',
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              level,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAutoDark ? Icons.dark_mode : Icons.light_mode,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      ThemeService.instance.mode == AppThemeMode.automatic
                          ? 'Auto theme: ${isAutoDark ? "Dark" : "Light"}'
                          : 'Theme: ${ThemeService.instance.mode.name}',
                    ),
                  ],
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
              Icons.lightbulb_outline,
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
