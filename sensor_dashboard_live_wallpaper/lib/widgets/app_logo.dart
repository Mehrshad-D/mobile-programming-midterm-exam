import 'package:flutter/material.dart';
import 'package:sensor_dashboard_live_wallpaper/constants/app_assets.dart';

/// Reusable app logo with consistent sizing across screens.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    required this.size,
    this.showShadow = false,
    this.borderRadius,
  });

  final double size;
  final bool showShadow;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppAssetSizes.logoRadius;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          AppAssets.logo,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
