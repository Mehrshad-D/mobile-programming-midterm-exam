import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:light/light.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:pedometer/pedometer.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:sensor_dashboard_live_wallpaper/models/sensor_info.dart';
import 'package:sensor_dashboard_live_wallpaper/services/location_service.dart';
import 'package:sensor_dashboard_live_wallpaper/services/permission_service.dart';
import 'package:sensor_dashboard_live_wallpaper/services/theme_service.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shake/shake.dart';

class SensorService extends ChangeNotifier {
  SensorService._();
  static final SensorService instance = SensorService._();

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  ShakeDetector? _shakeDetector;

  // Compass
  double? _heading;
  bool _compassAvailable = false;
  String _compassMessage = 'Initializing…';

  // GPS
  double? _latitude;
  double? _longitude;
  String _gpsMessage = 'Initializing…';

  // Light
  double? _lux;
  bool _lightAvailable = false;
  String _lightMessage = 'Initializing…';

  // Steps
  int _steps = 0;
  bool _pedometerAvailable = false;
  bool _pedometerStarted = false;
  String _pedometerMessage = 'Initializing…';

  // Proximity
  bool? _isNear;
  bool _proximityAvailable = false;
  String _proximityMessage = 'Initializing…';

  // Barometer
  double? _pressure;
  bool _barometerAvailable = false;
  String _barometerMessage = 'Initializing…';

  // NFC
  bool _nfcAvailable = false;
  String _nfcMessage = 'Initializing…';
  String _lastNfcTagId = '';
  String _lastNfcTechnology = '';
  String _lastNfcPayload = '';
  bool _nfcTagDetected = false;
  bool _nfcScanning = false;

  // Accelerometer (for parallax)
  double _accelX = 0;
  double _accelY = 0;

  bool _initialized = false;
  bool _refreshAnimating = false;

  // Getters
  double? get heading => _heading;
  bool get compassAvailable => _compassAvailable;
  String get compassMessage => _compassMessage;

  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String get gpsMessage => _gpsMessage;

  double? get lux => _lux;
  bool get lightAvailable => _lightAvailable;
  String get lightMessage => _lightMessage;

  int get steps => _steps;
  bool get pedometerAvailable => _pedometerAvailable;
  String get pedometerMessage => _pedometerMessage;

  bool? get isNear => _isNear;
  bool get proximityAvailable => _proximityAvailable;
  String get proximityMessage => _proximityMessage;

  double? get pressure => _pressure;
  bool get barometerAvailable => _barometerAvailable;
  String get barometerMessage => _barometerMessage;

  double? get estimatedAltitude {
    if (_pressure == null) return null;
    return (44330 * (1 - pow(_pressure! / 1013.25, 0.1903))).toDouble();
  }

  bool get nfcAvailable => _nfcAvailable;
  String get nfcMessage => _nfcMessage;
  String get lastNfcTagId => _lastNfcTagId;
  String get lastNfcTechnology => _lastNfcTechnology;
  String get lastNfcPayload => _lastNfcPayload;
  bool get nfcTagDetected => _nfcTagDetected;
  bool get nfcScanning => _nfcScanning;

  double get accelX => _accelX;
  double get accelY => _accelY;
  bool get refreshAnimating => _refreshAnimating;

  String get compassDirection {
    if (_heading == null) return '—';
    final h = _heading! % 360;
    if (h >= 337.5 || h < 22.5) return 'North';
    if (h >= 22.5 && h < 67.5) return 'North-East';
    if (h >= 67.5 && h < 112.5) return 'East';
    if (h >= 112.5 && h < 157.5) return 'South-East';
    if (h >= 157.5 && h < 202.5) return 'South';
    if (h >= 202.5 && h < 247.5) return 'South-West';
    if (h >= 247.5 && h < 292.5) return 'West';
    if (h >= 292.5 && h < 337.5) return 'North-West';
    return '—';
  }

  String get compassDisplayValue {
    if (!_compassAvailable || _heading == null) return _compassMessage;
    return '${_heading!.toStringAsFixed(0)}° $compassDirection';
  }

  String get gpsDisplayValue {
    if (_latitude != null && _longitude != null) {
      return '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}';
    }
    return _gpsMessage;
  }

  String get lightDisplayValue {
    if (!_lightAvailable || _lux == null) return _lightMessage;
    return '${_lux!.toStringAsFixed(0)} lux';
  }

  String get stepsDisplayValue {
    if (!_pedometerAvailable) return _pedometerMessage;
    return '$_steps steps';
  }

  String get proximityDisplayValue {
    if (!_proximityAvailable || _isNear == null) return _proximityMessage;
    return _isNear! ? 'Object is near' : 'Object is far';
  }

  String get barometerDisplayValue {
    if (!_barometerAvailable || _pressure == null) return _barometerMessage;
    final alt = estimatedAltitude;
    return '${_pressure!.toStringAsFixed(0)} hPa · ${alt?.toStringAsFixed(0) ?? '—'} m';
  }

  String get nfcDisplayValue {
    if (!_nfcAvailable) return _nfcMessage;
    if (_nfcTagDetected) return 'Tag: $_lastNfcTagId';
    if (_nfcScanning) return 'Scanning…';
    return 'Ready to scan';
  }

  List<SensorInfo> get allSensors => [
        SensorInfo(
          id: 'compass',
          name: 'Compass',
          description:
              'Magnetometer-based heading sensor showing cardinal direction.',
          icon: Icons.explore,
          updateFrequency: 'Real-time (~60 Hz)',
          value: compassDisplayValue,
          status: _compassAvailable
              ? SensorStatus.available
              : SensorStatus.unavailable,
          statusMessage: _compassMessage,
        ),
        SensorInfo(
          id: 'gps',
          name: 'GPS',
          description: 'Global Positioning System for latitude and longitude.',
          icon: Icons.location_on,
          updateFrequency: 'Every 5 m movement',
          value: gpsDisplayValue,
          status: (_latitude != null && _longitude != null)
              ? SensorStatus.available
              : (_gpsMessage.contains('denied')
                  ? SensorStatus.permissionDenied
                  : SensorStatus.unavailable),
          statusMessage: _gpsMessage,
        ),
        SensorInfo(
          id: 'light',
          name: 'Light Meter',
          description:
              'Ambient light sensor measuring illuminance in lux units.',
          icon: Icons.light_mode,
          updateFrequency: 'Real-time',
          value: lightDisplayValue,
          status: _lightAvailable
              ? SensorStatus.available
              : SensorStatus.unavailable,
          statusMessage: _lightMessage,
        ),
        SensorInfo(
          id: 'steps',
          name: 'Step Counter',
          description: 'Hardware step counter tracking daily walking activity.',
          icon: Icons.directions_walk,
          updateFrequency: 'Per step',
          value: stepsDisplayValue,
          status: _pedometerAvailable
              ? SensorStatus.available
              : SensorStatus.unavailable,
          statusMessage: _pedometerMessage,
        ),
        SensorInfo(
          id: 'proximity',
          name: 'Proximity',
          description:
              'Detects nearby objects using infrared proximity sensor.',
          icon: Icons.sensors,
          updateFrequency: 'Real-time',
          value: proximityDisplayValue,
          status: _proximityAvailable
              ? SensorStatus.available
              : SensorStatus.unavailable,
          statusMessage: _proximityMessage,
        ),
        SensorInfo(
          id: 'barometer',
          name: 'Barometer',
          description:
              'Atmospheric pressure sensor for weather and altitude estimation.',
          icon: Icons.speed,
          updateFrequency: 'Real-time',
          value: barometerDisplayValue,
          status: _barometerAvailable
              ? SensorStatus.available
              : SensorStatus.unavailable,
          statusMessage: _barometerMessage,
        ),
        SensorInfo(
          id: 'nfc',
          name: 'NFC Reader',
          description: 'Near Field Communication tag reader.',
          icon: Icons.nfc,
          updateFrequency: 'On tag detection',
          value: nfcDisplayValue,
          status: _nfcAvailable
              ? SensorStatus.available
              : SensorStatus.unavailable,
          statusMessage: _nfcMessage,
        ),
        SensorInfo(
          id: 'accelerometer',
          name: 'Accelerometer',
          description: 'Motion sensor used for parallax live wallpaper effect.',
          icon: Icons.vibration,
          updateFrequency: 'Real-time (~60 Hz)',
          value: 'X: ${_accelX.toStringAsFixed(2)}, Y: ${_accelY.toStringAsFixed(2)}',
          status: SensorStatus.available,
          statusMessage: 'Active',
        ),
      ];

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await PermissionService.instance.initialize();
    _startAccelerometer();
    _startCompass();
    _startLightSensor();
    _startPedometer();
    _startProximity();
    _startBarometer();
    await _checkNfc();
    await _refreshGps();
    _startShakeDetection();
  }

  void _startAccelerometer() {
    try {
      _subscriptions.add(
        accelerometerEventStream().listen(
          (event) {
            _accelX = event.x;
            _accelY = event.y;
            notifyListeners();
          },
          onError: (Object e) {
            debugPrint('Accelerometer error: $e');
          },
        ),
      );
    } catch (e) {
      debugPrint('Accelerometer start error: $e');
    }
  }

  void _startCompass() {
    try {
      if (FlutterCompass.events == null) {
        _compassAvailable = false;
        _compassMessage = 'This device does not support a compass.';
        notifyListeners();
        return;
      }

      _subscriptions.add(
        FlutterCompass.events!.listen(
          (event) {
            if (event.heading != null) {
              _heading = event.heading;
              _compassAvailable = true;
              _compassMessage = 'Active';
              notifyListeners();
            }
          },
          onError: (Object e) {
            _compassAvailable = false;
            _compassMessage = 'This device does not support a compass.';
            notifyListeners();
          },
        ),
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (_heading == null && !_compassAvailable) {
          _compassMessage = 'This device does not support a compass.';
          notifyListeners();
        }
      });
    } catch (e) {
      _compassAvailable = false;
      _compassMessage = 'This device does not support a compass.';
      notifyListeners();
    }
  }

  void _startLightSensor() {
    try {
      _subscriptions.add(
        Light().lightSensorStream.listen(
          (lux) {
            _lux = lux.toDouble();
            _lightAvailable = true;
            _lightMessage = 'Active';
            ThemeService.instance.updateLux(_lux!);
            notifyListeners();
          },
          onError: (Object e) {
            _lightAvailable = false;
            _lightMessage = 'Light sensor is not available.';
            notifyListeners();
          },
        ),
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (_lux == null && !_lightAvailable) {
          _lightMessage = 'Light sensor is not available.';
          notifyListeners();
        }
      });
    } catch (e) {
      _lightAvailable = false;
      _lightMessage = 'Light sensor is not available.';
      notifyListeners();
    }
  }

  void _startPedometer() {
    if (_pedometerStarted) return;

    if (!PermissionService.instance.activityRecognitionGranted) {
      _pedometerAvailable = false;
      _pedometerMessage =
          'Activity recognition permission is required for the step counter.';
      notifyListeners();
      return;
    }

    _pedometerStarted = true;

    try {
      _subscriptions.add(
        Pedometer.stepCountStream.listen(
          (event) {
            _steps = event.steps;
            _pedometerAvailable = true;
            _pedometerMessage = 'Active';
            notifyListeners();
          },
          onError: (Object e) {
            _pedometerAvailable = false;
            _pedometerMessage =
                'Step counter hardware is unavailable. Most emulators lack this sensor — use a physical device.';
            notifyListeners();
          },
        ),
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (!_pedometerAvailable && _steps == 0) {
          _pedometerMessage =
              'Step counter hardware is unavailable. Most emulators lack this sensor — use a physical device.';
          notifyListeners();
        }
      });
    } catch (e) {
      _pedometerAvailable = false;
      _pedometerMessage =
          'Step counter hardware is unavailable. Most emulators lack this sensor — use a physical device.';
      notifyListeners();
    }
  }

  void _startProximity() {
    try {
      _subscriptions.add(
        ProximitySensor.events.listen(
          (int value) {
            _isNear = value < 1;
            _proximityAvailable = true;
            _proximityMessage = 'Active';
            notifyListeners();
          },
          onError: (Object e) {
            _proximityAvailable = false;
            _proximityMessage = 'Proximity sensor is not available.';
            notifyListeners();
          },
        ),
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (_isNear == null && !_proximityAvailable) {
          _proximityMessage = 'Proximity sensor is not available.';
          notifyListeners();
        }
      });
    } catch (e) {
      _proximityAvailable = false;
      _proximityMessage = 'Proximity sensor is not available.';
      notifyListeners();
    }
  }

  void _startBarometer() {
    try {
      _subscriptions.add(
        barometerEventStream().listen(
          (event) {
            _pressure = event.pressure;
            _barometerAvailable = true;
            _barometerMessage = 'Active';
            notifyListeners();
          },
          onError: (Object e) {
            _barometerAvailable = false;
            _barometerMessage =
                'This sensor is not supported on your device.';
            notifyListeners();
          },
        ),
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (_pressure == null && !_barometerAvailable) {
          _barometerMessage = 'This sensor is not supported on your device.';
          notifyListeners();
        }
      });
    } catch (e) {
      _barometerAvailable = false;
      _barometerMessage = 'This sensor is not supported on your device.';
      notifyListeners();
    }
  }

  Future<void> _checkNfc() async {
    try {
      _nfcAvailable = await NfcManager.instance.isAvailable();
      if (_nfcAvailable) {
        _nfcMessage = 'Ready to scan';
      } else {
        _nfcMessage =
            'NFC is not available. On emulator: Extended controls → NFC → simulate a tag. On device: enable NFC in settings.';
      }
      notifyListeners();
    } catch (e) {
      _nfcAvailable = false;
      _nfcMessage =
          'NFC is not available. On emulator: Extended controls → NFC → simulate a tag.';
      notifyListeners();
    }
  }

  Future<void> refreshNfcAvailability() => _checkNfc();

  Future<void> startNfcScan() async {
    if (!_nfcAvailable) return;

    try {
      _nfcScanning = true;
      _nfcTagDetected = false;
      notifyListeners();

      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            final data = tag.data;
            _lastNfcTagId = _extractTagId(data);
            _lastNfcTechnology = _extractTechnology(data);
            _lastNfcPayload = _extractPayload(data);
            _nfcTagDetected = true;
            _nfcScanning = false;
            notifyListeners();
          } catch (e) {
            debugPrint('NFC tag parse error: $e');
          }
        },
      );
    } catch (e) {
      _nfcScanning = false;
      _nfcMessage = 'NFC scan failed: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> stopNfcScan() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (e) {
      debugPrint('NFC stop error: $e');
    }
    _nfcScanning = false;
    notifyListeners();
  }

  String _extractTagId(Map<String, dynamic> data) {
    try {
      final nfca = data['nfca'];
      if (nfca != null && nfca['identifier'] != null) {
        return _bytesToHex(List<int>.from(nfca['identifier'] as List));
      }
      final nfcb = data['nfcb'];
      if (nfcb != null && nfcb['identifier'] != null) {
        return _bytesToHex(List<int>.from(nfcb['identifier'] as List));
      }
      final nfcf = data['nfcf'];
      if (nfcf != null && nfcf['identifier'] != null) {
        return _bytesToHex(List<int>.from(nfcf['identifier'] as List));
      }
      final nfcv = data['nfcv'];
      if (nfcv != null && nfcv['identifier'] != null) {
        return _bytesToHex(List<int>.from(nfcv['identifier'] as List));
      }
    } catch (e) {
      debugPrint('Tag ID extraction error: $e');
    }
    return 'Unknown';
  }

  String _extractTechnology(Map<String, dynamic> data) {
    final techs = <String>[];
    if (data.containsKey('nfca')) techs.add('NFC-A');
    if (data.containsKey('nfcb')) techs.add('NFC-B');
    if (data.containsKey('nfcf')) techs.add('NFC-F');
    if (data.containsKey('nfcv')) techs.add('NFC-V');
    if (data.containsKey('isodep')) techs.add('ISO-DEP');
    if (data.containsKey('mifareultralight')) techs.add('Mifare Ultralight');
    if (data.containsKey('mifareclassic')) techs.add('Mifare Classic');
    if (data.containsKey('ndef')) techs.add('NDEF');
    return techs.isEmpty ? 'Unknown' : techs.join(', ');
  }

  String _extractPayload(Map<String, dynamic> data) {
    try {
      final ndef = data['ndef'];
      if (ndef != null) {
        final cached = ndef['cachedMessage'];
        if (cached != null) {
          final records = cached['records'] as List?;
          if (records != null && records.isNotEmpty) {
            final record = records.first as Map;
            final payload = record['payload'];
            if (payload != null) {
              final bytes = List<int>.from(payload as List);
              if (bytes.length > 3) {
                return String.fromCharCodes(bytes.sublist(3));
              }
              return String.fromCharCodes(bytes);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Payload extraction error: $e');
    }
    return 'No readable payload';
  }

  String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
  }

  Future<void> _refreshGps() async {
    final position = await LocationService.instance.getCurrentPosition();
    if (position != null) {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _gpsMessage = 'Active';
    } else {
      _gpsMessage = LocationService.instance.errorMessage;
    }
    notifyListeners();
  }

  void _startShakeDetection() {
    try {
      _shakeDetector?.stopListening();
      _shakeDetector = ShakeDetector.autoStart(
        onPhoneShake: (_) {
          onShakeDetected();
        },
        shakeThresholdGravity: 1.7,
        shakeSlopTimeMS: 600,
        useFilter: true,
      );
    } catch (e) {
      debugPrint('Shake detection error: $e');
    }
  }

  VoidCallback? onShakeCallback;

  void onShakeDetected() {
    refreshAll();
    onShakeCallback?.call();
  }

  Future<void> refreshAll() async {
    _refreshAnimating = true;
    notifyListeners();

    await _refreshGps();
    if (!PermissionService.instance.activityRecognitionGranted) {
      await PermissionService.instance.ensureActivityRecognitionPermission();
    }
    if (PermissionService.instance.activityRecognitionGranted &&
        !_pedometerAvailable) {
      _startPedometer();
    }
    await refreshNfcAvailability();

    await Future<void>.delayed(const Duration(milliseconds: 600));
    _refreshAnimating = false;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _shakeDetector?.stopListening();
    stopNfcScan();
    super.dispose();
  }
}
