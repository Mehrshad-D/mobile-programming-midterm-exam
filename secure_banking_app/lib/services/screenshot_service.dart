import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../utils/app_config.dart';
import '../utils/platform_helper.dart';
import 'security_service.dart';

class ScreenshotService {
  ScreenshotService._();

  static final ScreenshotService instance = ScreenshotService._();

  static const MethodChannel _channel =
      MethodChannel(AppConfig.securityChannel);

  int _refCount = 0;
  bool _nativeEnabled = false;

  bool get isProtectionActive => _nativeEnabled;

  /// Enables FLAG_SECURE on Android to block screenshots and screen recording.
  Future<void> enableProtection() async {
    _refCount++;
    if (_refCount == 1) {
      await _setNativeProtection(true);
    }
    _syncReportStatus();
  }

  /// Disables FLAG_SECURE only when no sensitive screen is visible.
  Future<void> disableProtection() async {
    if (_refCount == 0) {
      return;
    }
    _refCount--;
    if (_refCount == 0) {
      await _setNativeProtection(false);
    }
    _syncReportStatus();
  }

  /// Re-applies FLAG_SECURE if a sensitive screen is still active (e.g. after resume).
  Future<void> reapplyIfNeeded() async {
    if (_refCount > 0 && isAndroid) {
      await _setNativeProtection(true);
      _syncReportStatus();
    }
  }

  void _syncReportStatus() {
    SecurityService.instance.updateScreenshotBlockingStatus(_nativeEnabled);
  }

  Future<void> _setNativeProtection(bool enable) async {
    if (!isAndroid) {
      _nativeEnabled = false;
      return;
    }

    try {
      await _channel.invokeMethod<void>(
        enable ? 'enableScreenshotProtection' : 'disableScreenshotProtection',
      );
      _nativeEnabled = enable;
    } catch (e) {
      debugPrint('Screenshot protection error: $e');
      _nativeEnabled = false;
    }
  }
}
