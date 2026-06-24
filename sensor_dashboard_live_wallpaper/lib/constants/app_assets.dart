/// Centralized asset paths for images bundled in [assets/].
abstract final class AppAssets {
  static const String logo = 'assets/logo/logo.png';
  static const String splash = 'assets/splash/splash.png';
}

/// Display sizes tuned for phone screens (logical pixels).
abstract final class AppAssetSizes {
  /// Logo on the Flutter splash screen.
  static const double splashLogo = 140;

  /// Logo on the biometric lock screen.
  static const double lockLogo = 96;

  /// Corner radius matching the logo artwork.
  static const double logoRadius = 28;
}
