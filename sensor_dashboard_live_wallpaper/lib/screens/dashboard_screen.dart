import 'package:flutter/material.dart';
import 'package:sensor_dashboard_live_wallpaper/screens/compass_screen.dart';
import 'package:sensor_dashboard_live_wallpaper/screens/light_meter_screen.dart';
import 'package:sensor_dashboard_live_wallpaper/screens/map_screen.dart';
import 'package:sensor_dashboard_live_wallpaper/screens/nfc_screen.dart';
import 'package:sensor_dashboard_live_wallpaper/screens/sensor_details_screen.dart';
import 'package:sensor_dashboard_live_wallpaper/screens/step_counter_screen.dart';
import 'package:sensor_dashboard_live_wallpaper/services/sensor_service.dart';
import 'package:sensor_dashboard_live_wallpaper/services/theme_service.dart';
import 'package:sensor_dashboard_live_wallpaper/widgets/live_background.dart';
import 'package:sensor_dashboard_live_wallpaper/widgets/sensor_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _refreshController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    SensorService.instance.onShakeCallback = _onShakeDetected;
  }

  void _onShakeDetected() {
    if (!mounted) return;
    _refreshController.forward(from: 0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.vibration, color: Colors.white),
            SizedBox(width: 12),
            Text('Shake Detected!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _refresh() async {
    _refreshController.forward(from: 0);
    await SensorService.instance.refreshAll();
  }

  void _navigate(Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  void dispose() {
    SensorService.instance.onShakeCallback = null;
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        SensorService.instance,
        ThemeService.instance,
      ]),
      builder: (context, _) {
        final service = SensorService.instance;
        final theme = Theme.of(context);

        return Scaffold(
          key: _scaffoldKey,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text('Sensor Dashboard'),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                    theme.colorScheme.tertiary,
                  ],
                ),
              ),
            ),
            actions: [
              RotationTransition(
                turns: _refreshController,
                child: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refresh,
                  tooltip: 'Refresh',
                ),
              ),
              PopupMenuButton<AppThemeMode>(
                icon: const Icon(Icons.brightness_6),
                tooltip: 'Theme',
                onSelected: ThemeService.instance.setMode,
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: AppThemeMode.light,
                    child: ListTile(
                      leading: Icon(Icons.light_mode),
                      title: Text('Light'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: AppThemeMode.dark,
                    child: ListTile(
                      leading: Icon(Icons.dark_mode),
                      title: Text('Dark'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: AppThemeMode.automatic,
                    child: ListTile(
                      leading: Icon(Icons.auto_mode),
                      title: Text('Automatic'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: LiveBackground(
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: GridView.count(
                  padding: const EdgeInsets.all(16),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                  children: [
                    SensorCard(
                      title: 'Compass',
                      value: service.compassDisplayValue,
                      icon: Icons.explore,
                      isUnavailable: !service.compassAvailable,
                      gradientColors: const [
                        Color(0xFF667EEA),
                        Color(0xFF764BA2),
                      ],
                      onTap: () => _navigate(const CompassScreen()),
                    ),
                    SensorCard(
                      title: 'GPS',
                      value: service.gpsDisplayValue,
                      icon: Icons.location_on,
                      isUnavailable: service.latitude == null,
                      gradientColors: const [
                        Color(0xFF11998E),
                        Color(0xFF38EF7D),
                      ],
                      onTap: () => _navigate(const MapScreen()),
                    ),
                    SensorCard(
                      title: 'Light Meter',
                      value: service.lightDisplayValue,
                      icon: Icons.light_mode,
                      isUnavailable: !service.lightAvailable,
                      gradientColors: const [
                        Color(0xFFF7971E),
                        Color(0xFFFFD200),
                      ],
                      onTap: () => _navigate(const LightMeterScreen()),
                    ),
                    SensorCard(
                      title: 'Step Counter',
                      value: service.stepsDisplayValue,
                      icon: Icons.directions_walk,
                      isUnavailable: !service.pedometerAvailable,
                      gradientColors: const [
                        Color(0xFFFC466B),
                        Color(0xFF3F5EFB),
                      ],
                      onTap: () => _navigate(const StepCounterScreen()),
                    ),
                    SensorCard(
                      title: 'Proximity',
                      value: service.proximityDisplayValue,
                      icon: Icons.sensors,
                      isUnavailable: !service.proximityAvailable,
                      highlightColor: service.isNear == true
                          ? Colors.orange.shade300
                          : null,
                      gradientColors: service.isNear == true
                          ? [
                              Colors.orange.shade400,
                              Colors.deepOrange.shade300,
                            ]
                          : [
                              const Color(0xFF4FACFE),
                              const Color(0xFF00F2FE),
                            ],
                      onTap: () => _navigate(const _ProximityDetailScreen()),
                    ),
                    SensorCard(
                      title: 'Barometer',
                      value: service.barometerAvailable && service.pressure != null
                          ? '${service.pressure!.toStringAsFixed(0)} hPa'
                          : service.barometerMessage,
                      subtitle: service.estimatedAltitude != null
                          ? 'Alt: ${service.estimatedAltitude!.toStringAsFixed(0)} m'
                          : null,
                      icon: Icons.speed,
                      isUnavailable: !service.barometerAvailable,
                      gradientColors: const [
                        Color(0xFF8E2DE2),
                        Color(0xFF4A00E0),
                      ],
                      onTap: () => _navigate(const _BarometerDetailScreen()),
                    ),
                    SensorCard(
                      title: 'NFC',
                      value: service.nfcDisplayValue,
                      icon: Icons.nfc,
                      isUnavailable: !service.nfcAvailable,
                      gradientColors: const [
                        Color(0xFF0F2027),
                        Color(0xFF203A43),
                      ],
                      onTap: () => _navigate(const NfcScreen()),
                    ),
                    SensorCard(
                      title: 'Sensor Details',
                      value: '${service.allSensors.where((s) => s.isAvailable).length} active',
                      icon: Icons.list_alt,
                      gradientColors: const [
                        Color(0xFF536976),
                        Color(0xFF292E49),
                      ],
                      onTap: () => _navigate(const SensorDetailsScreen()),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: RotationTransition(
            turns: _refreshController,
            child: FloatingActionButton.extended(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ),
        );
      },
    );
  }
}

class _ProximityDetailScreen extends StatelessWidget {
  const _ProximityDetailScreen();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SensorService.instance,
      builder: (context, _) {
        final service = SensorService.instance;
        final theme = Theme.of(context);
        final isNear = service.isNear;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text('Proximity Sensor'),
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
              child: service.proximityAvailable && isNear != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isNear
                                  ? Colors.orange.withValues(alpha: 0.3)
                                  : Colors.green.withValues(alpha: 0.3),
                              border: Border.all(
                                color: isNear ? Colors.orange : Colors.green,
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              isNear ? Icons.warning_amber : Icons.check_circle,
                              size: 72,
                              color: isNear ? Colors.orange : Colors.green,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            isNear ? 'Object is near' : 'Object is far',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isNear ? Colors.orange : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _Unavailable(message: service.proximityMessage),
            ),
          ),
        );
      },
    );
  }
}

class _BarometerDetailScreen extends StatelessWidget {
  const _BarometerDetailScreen();

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
            title: const Text('Barometer'),
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
              child: service.barometerAvailable && service.pressure != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.speed,
                              size: 80,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Pressure',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${service.pressure!.toStringAsFixed(1)} hPa',
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Estimated Altitude',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${service.estimatedAltitude?.toStringAsFixed(0) ?? '—'} m',
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _Unavailable(message: service.barometerMessage),
            ),
          ),
        );
      },
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.message});

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
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
