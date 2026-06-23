import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../utils/app_theme.dart';
import 'biometric_lock_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      setState(() => _status = 'Setting up database...');
      await Future<void>.delayed(const Duration(milliseconds: 400));

      await AppServices.instance.initialize();

      setState(() => _status = 'Preparing encryption...');
      await Future<void>.delayed(const Duration(milliseconds: 400));

      setState(() => _status = 'Securing storage...');
      await Future<void>.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        fadeSlideRoute(const BiometricLockScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Initialization failed. Please restart the app.');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.credit_card,
                  size: 72,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Encrypted Bank Card',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Educational purposes only',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 48),
              RotationTransition(
                turns: _controller,
                child: const Icon(
                  Icons.sync,
                  color: Colors.white70,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _status,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
