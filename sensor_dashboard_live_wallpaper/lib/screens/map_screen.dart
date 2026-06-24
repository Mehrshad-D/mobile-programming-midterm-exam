import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sensor_dashboard_live_wallpaper/constants/app_config.dart';
import 'package:sensor_dashboard_live_wallpaper/services/location_service.dart';
import 'package:sensor_dashboard_live_wallpaper/services/permission_service.dart';
import 'package:sensor_dashboard_live_wallpaper/services/sensor_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  String _errorMessage = '';
  bool _loading = true;
  bool _mapReady = false;
  StreamSubscription<Position>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _seedFromCachedLocation();
    _loadLocation();
    _startLocationStream();
  }

  void _seedFromCachedLocation() {
    final service = SensorService.instance;
    if (service.latitude != null && service.longitude != null) {
      _currentPosition = LatLng(service.latitude!, service.longitude!);
    } else {
      final cached = LocationService.instance.lastPosition;
      if (cached != null) {
        _currentPosition = LatLng(cached.latitude, cached.longitude);
      }
    }
  }

  void _startLocationStream() {
    _positionSubscription?.cancel();
    _positionSubscription = LocationService.instance.getPositionStream().listen(
      (position) {
        final latLng = LatLng(position.latitude, position.longitude);
        setState(() => _currentPosition = latLng);
        _centerMapOn(latLng);
      },
      onError: (_) {},
    );
  }

  Future<void> _loadLocation() async {
    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    final hasPermission =
        await PermissionService.instance.ensureLocationPermission();
    if (!hasPermission) {
      setState(() {
        _loading = false;
        _errorMessage =
            'Location permission denied. Please grant location access to view the map.';
      });
      return;
    }

    final position = await LocationService.instance.getCurrentPosition();
    if (position != null) {
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentPosition = latLng;
        _loading = false;
      });
      _centerMapOn(latLng);
    } else if (_currentPosition != null) {
      setState(() => _loading = false);
      _centerMapOn(_currentPosition!);
    } else {
      setState(() {
        _loading = false;
        _errorMessage = LocationService.instance.errorMessage;
      });
    }
  }

  void _centerMapOn(LatLng latLng) {
    if (!_mapReady) return;
    _mapController.move(latLng, _mapController.camera.zoom);
  }

  void _onMapReady() {
    _mapReady = true;
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 16);
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Map'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _loadLocation,
            tooltip: 'Refresh location',
          ),
        ],
      ),
      body: _loading && _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty && _currentPosition == null
              ? _ErrorView(message: _errorMessage, onRetry: _loadLocation)
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentPosition ??
                            const LatLng(37.422, -122.084),
                        initialZoom: 16,
                        minZoom: 3,
                        maxZoom: 19,
                        onMapReady: _onMapReady,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: AppConfig.packageName,
                        ),
                        if (_currentPosition != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _currentPosition!,
                                width: 40,
                                height: 40,
                                alignment: Alignment.bottomCenter,
                                child: Icon(
                                  Icons.location_on,
                                  size: 40,
                                  color: theme.colorScheme.error,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 4,
                                      color: Colors.black26,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (_loading)
                      const Positioned(
                        top: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Updating location…'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_currentPosition != null)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Current Location',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                Text(
                                  'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Map tiles © OpenStreetMap contributors',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 16,
                      bottom: _currentPosition != null ? 140 : 16,
                      child: FloatingActionButton.small(
                        onPressed: () {
                          if (_currentPosition != null) {
                            _mapController.move(_currentPosition!, 16);
                          } else {
                            _loadLocation();
                          }
                        },
                        tooltip: 'Center on my location',
                        child: const Icon(Icons.gps_fixed),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
