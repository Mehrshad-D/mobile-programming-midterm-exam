import 'package:flutter/material.dart';
import 'package:sensor_dashboard_live_wallpaper/constants/app_assets.dart';
import 'package:sensor_dashboard_live_wallpaper/screens/dashboard_screen.dart';
import 'package:sensor_dashboard_live_wallpaper/services/biometric_service.dart';
import 'package:sensor_dashboard_live_wallpaper/widgets/app_logo.dart';
import 'package:sensor_dashboard_live_wallpaper/widgets/live_background.dart';

class BiometricLockScreen extends StatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen>
    with SingleTickerProviderStateMixin {
  bool _isAuthenticating = false;
  String _statusMessage = 'Authenticate to continue';
  late AnimationController _lockController;

  @override
  void initState() {
    super.initState();
    _lockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _statusMessage = 'Waiting for authentication…';
    });

    final success = await BiometricService.instance.authenticate();

    if (!mounted) return;

    if (success) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const DashboardScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
    } else {
      setState(() {
        _isAuthenticating = false;
        _statusMessage = 'Authentication failed. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    _lockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: LiveBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.95, end: 1.05).animate(
                      CurvedAnimation(
                        parent: _lockController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: const AppLogo(
                      size: AppAssetSizes.lockLogo,
                      showShadow: true,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Biometric Lock',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use fingerprint, face, or device PIN',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 48),
                  if (_isAuthenticating)
                    const CircularProgressIndicator()
                  else
                    FilledButton.icon(
                      onPressed: _authenticate,
                      icon: const Icon(Icons.lock_open),
                      label: const Text('Retry Authentication'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
