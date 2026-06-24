import 'package:flutter/material.dart';

import '../services/screenshot_service.dart';

/// Enables FLAG_SECURE while this screen is visible.
/// Uses reference counting so nested sensitive screens stay protected.
mixin SecureScreenMixin<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScreenshotService.instance.enableProtection();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ScreenshotService.instance.disableProtection();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ScreenshotService.instance.reapplyIfNeeded();
    }
  }
}
