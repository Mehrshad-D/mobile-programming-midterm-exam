import 'package:flutter/material.dart';

import '../services/security_service.dart';
import '../widgets/app_logo.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  bool _environmentUnsafe = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final report = await SecurityService.instance.runSecurityChecks();

      if (!mounted) {
        return;
      }

      setState(() {
        _environmentUnsafe = !report.environmentSafe;
        _isLoading = false;
      });

      if (!report.environmentSafe) {
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 800));

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _environmentUnsafe = false;
        _isLoading = false;
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_environmentUnsafe) {
      return Scaffold(
        backgroundColor: colorScheme.errorContainer,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(height: 80),
                const SizedBox(height: 24),
                Text(
                  'محیط ناامن',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'به دلیل ناامن بودن محیط اجرا، امکان استفاده از برنامه وجود ندارد.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onErrorContainer,
                        height: 1.6,
                      ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 32),
                FilledButton.tonal(
                  onPressed: _initialize,
                  child: const Text('بررسی مجدد'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const SplashImage(),
          if (_isLoading)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 48,
              child: Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
