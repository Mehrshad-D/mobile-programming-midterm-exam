import 'package:flutter/material.dart';

import '../utils/app_assets.dart';

/// Displays [AppAssets.logo] with correct 3:2 aspect ratio (no cropping).
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height = 72,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.logo,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

/// Displays [AppAssets.splash] scaled to fit the screen without cropping.
class SplashImage extends StatelessWidget {
  const SplashImage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final box = _fitAspectRatio(
      maxWidth: size.width,
      maxHeight: size.height,
      aspectRatio: AppAssets.imageAspectRatio,
    );

    return ColoredBox(
      color: const Color(AppAssets.splashBackground),
      child: Center(
        child: SizedBox(
          width: box.width,
          height: box.height,
          child: Image.asset(
            AppAssets.splash,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }

  static Size _fitAspectRatio({
    required double maxWidth,
    required double maxHeight,
    required double aspectRatio,
  }) {
    var width = maxWidth;
    var height = width / aspectRatio;

    if (height > maxHeight) {
      height = maxHeight;
      width = height * aspectRatio;
    }

    return Size(width, height);
  }
}
