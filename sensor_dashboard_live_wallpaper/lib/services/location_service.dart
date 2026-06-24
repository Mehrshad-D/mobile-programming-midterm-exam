import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensor_dashboard_live_wallpaper/services/permission_service.dart';

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  Position? _lastPosition;
  String _errorMessage = '';

  Position? get lastPosition => _lastPosition;
  String get errorMessage => _errorMessage;
  bool get hasLocation => _lastPosition != null;

  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission =
          await PermissionService.instance.ensureLocationPermission();
      if (!hasPermission) {
        _errorMessage =
            'Location permission denied. Enable location access in settings.';
        return null;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage =
            'GPS is unavailable. Please enable location services on your device.';
        return null;
      }

      try {
        _lastPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            timeLimit: Duration(seconds: 30),
          ),
        );
      } catch (e) {
        debugPrint('getCurrentPosition failed, trying last known: $e');
        _lastPosition = await Geolocator.getLastKnownPosition();
      }

      if (_lastPosition == null) {
        _errorMessage =
            'Unable to retrieve GPS location. GPS may be unavailable.';
        return null;
      }

      _errorMessage = '';
      return _lastPosition;
    } catch (e) {
      debugPrint('Location error: $e');
      _errorMessage =
          'Unable to retrieve GPS location. GPS may be unavailable.';
      return null;
    }
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );
  }
}
