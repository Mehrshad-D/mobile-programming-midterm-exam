import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  PermissionService._();
  static final PermissionService instance = PermissionService._();

  bool _initialized = false;
  bool locationGranted = false;
  bool activityRecognitionGranted = false;
  bool nfcGranted = true;
  bool sensorsGranted = true;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _requestLocationPermission();
    await _requestActivityRecognitionPermission();
    await _checkNfcAvailability();
  }

  Future<bool> _requestLocationPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationGranted = false;
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      locationGranted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      return locationGranted;
    } catch (e) {
      debugPrint('Location permission error: $e');
      locationGranted = false;
      return false;
    }
  }

  Future<bool> requestLocationWithDialog() async {
    final granted = await _requestLocationPermission();
    if (!granted) {
      final status = await Permission.location.status;
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    }
    return locationGranted;
  }

  Future<bool> _requestActivityRecognitionPermission() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final info = await DeviceInfoPlugin().androidInfo;
        if (info.version.sdkInt >= 29) {
          final status = await Permission.activityRecognition.request();
          activityRecognitionGranted = status.isGranted;
          return activityRecognitionGranted;
        }
      }
      activityRecognitionGranted = true;
      return true;
    } catch (e) {
      debugPrint('Activity recognition permission error: $e');
      activityRecognitionGranted = false;
      return false;
    }
  }

  Future<bool> requestActivityRecognitionWithDialog() async {
    final granted = await _requestActivityRecognitionPermission();
    if (!granted) {
      final status = await Permission.activityRecognition.status;
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    }
    return activityRecognitionGranted;
  }

  Future<void> _checkNfcAvailability() async {
    try {
      nfcGranted = true;
    } catch (e) {
      debugPrint('NFC check error: $e');
      nfcGranted = false;
    }
  }

  Future<bool> ensureLocationPermission() async {
    if (locationGranted) return true;
    return requestLocationWithDialog();
  }

  Future<bool> ensureActivityRecognitionPermission() async {
    if (activityRecognitionGranted) return true;
    return requestActivityRecognitionWithDialog();
  }
}
