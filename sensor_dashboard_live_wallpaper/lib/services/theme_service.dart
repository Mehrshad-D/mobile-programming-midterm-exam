import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, automatic }

class ThemeService extends ChangeNotifier {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  AppThemeMode _mode = AppThemeMode.automatic;
  double _currentLux = 500;
  static const double _luxThreshold = 50;

  AppThemeMode get mode => _mode;
  double get currentLux => _currentLux;

  ThemeMode get materialThemeMode {
    switch (_mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.automatic:
        return ThemeMode.system;
    }
  }

  bool get isDarkFromLightSensor => _currentLux < _luxThreshold;

  Brightness get effectiveBrightness {
    switch (_mode) {
      case AppThemeMode.light:
        return Brightness.light;
      case AppThemeMode.dark:
        return Brightness.dark;
      case AppThemeMode.automatic:
        return isDarkFromLightSensor ? Brightness.dark : Brightness.light;
    }
  }

  void setMode(AppThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  void updateLux(double lux) {
    _currentLux = lux;
    if (_mode == AppThemeMode.automatic) {
      notifyListeners();
    }
  }

  ThemeData get lightTheme => _buildTheme(Brightness.light);
  ThemeData get darkTheme => _buildTheme(Brightness.dark);

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final seedColor = isDark ? Colors.indigo : Colors.deepPurple;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
