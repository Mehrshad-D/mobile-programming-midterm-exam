import 'package:flutter/material.dart';
import 'package:sensor_dashboard_live_wallpaper/screens/splash_screen.dart';
import 'package:sensor_dashboard_live_wallpaper/services/theme_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SensorDashboardApp());
}

class SensorDashboardApp extends StatefulWidget {
  const SensorDashboardApp({super.key});

  @override
  State<SensorDashboardApp> createState() => _SensorDashboardAppState();
}

class _SensorDashboardAppState extends State<SensorDashboardApp> {
  final ThemeService _themeService = ThemeService.instance;

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensor Dashboard',
      debugShowCheckedModeBanner: false,
      theme: _themeService.lightTheme,
      darkTheme: _themeService.darkTheme,
      themeMode: _resolveThemeMode(),
      home: const SplashScreen(),
    );
  }

  ThemeMode _resolveThemeMode() {
    switch (_themeService.mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.automatic:
        return _themeService.isDarkFromLightSensor
            ? ThemeMode.dark
            : ThemeMode.light;
    }
  }
}
