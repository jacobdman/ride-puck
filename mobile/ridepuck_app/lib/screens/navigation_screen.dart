import 'package:flutter/material.dart';
import 'package:mapbox_navigation_sdk/mapbox_navigation_sdk.dart';

import '../config/mapbox_config.dart';
import '../models/dashboard_state.dart';
import '../models/navigation_progress.dart';
import '../services/dashboard_state_builder.dart';
import '../services/gps_service.dart';
import '../services/navigation_service.dart';
import '../widgets/dashboard_preview_card.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({
    super.key,
    required this.gpsService,
  });

  final GpsService gpsService;

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final NavigationService _navigationService = NavigationService();

  MapBoxOptions? _mapOptions;
  NavigationDestination _selectedDestination = NavigationDestination.presets.first;
  bool _simulateRoute = true;
  bool _initialized = false;
  bool _buildingRoute = false;
  String? _error;

  GpsSnapshot _gps = GpsSnapshot.unavailable();
  NavigationProgress _progress = NavigationProgress.idle;
  DashboardState _previewState = DashboardStateBuilder.mockRide();

  @override
  void initState() {
    super.initState();
    _gps = widget.gpsService.latest;
    widget.gpsService.snapshots.listen((snapshot) {
      if (!mounted) {
        return;
      }
      setState(() {
        _gps = snapshot;
        _refreshPreview();
      });
    });
    _navigationService.progress.listen((progress) {
      if (!mounted) {
        return;
      }
      setState(() {
        _progress = progress;
        _refreshPreview();
      });
    });
    _prepareNavigation();
  }

  @override
  void dispose() {
    _navigationService.dispose();
    super.dispose();
  }

  Future<void> _prepareNavigation() async {
    if (!MapboxConfig.isConfigured) {
      setState(() {
        _error = 'Configure MAPBOX_ACCESS_TOKEN before starting navigation';
      });
      return;
    }

    if (!_gps.available) {
      final ready = await widget.gpsService.ensureReady();
      if (!ready) {
        setState(() {
          _error = widget.gpsService.error ?? 'GPS is not ready';
        });
        return;
      }
      await widget.gpsService.start();
      _gps = widget.gpsService.latest;
    }

    final latitude = _gps.latitude ?? 42.886448;
    final longitude = _gps.longitude ?? -78.878372;

    _mapOptions = MapBoxOptions(
      initialLatitude: latitude,
      initialLongitude: longitude,
      zoom: 14,
      tilt: 0,
      bearing: 0,
      alternatives: true,
      voiceInstructionsEnabled: true,
      bannerInstructionsEnabled: true,
      allowsUTurnAtWayPoints: true,
      mode: MapBoxNavigationMode.drivingWithTraffic,
      units: VoiceUnits.imperial,
      simulateRoute: _simulateRoute,
      language: 'en',
    );

    await _navigationService.initialize(
      initialLatitude: latitude,
      initialLongitude: longitude,
      simulateRoute: _simulateRoute,
    );

    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  void _refreshPreview() {
    _previewState = DashboardStateBuilder.fromNavigation(
      ride: _gps,
      progress: _progress,
    );
  }

  Future<void> _buildRoute() async {
    if (_gps.latitude == null || _gps.longitude == null) {
      setState(() {
        _error = 'Waiting for GPS fix before building a route';
      });
      return;
    }

    setState(() {
      _buildingRoute = true;
      _error = null;
    });

    try {
      final origin = WayPoint(
        name: 'Current location',
        latitude: _gps.latitude!,
        longitude: _gps.longitude!,
      );
      await _navigationService.buildRoute(
        origin: origin,
        destination: _selectedDestination.toWayPoint(),
      );
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _buildingRoute = false;
        });
      }
    }
  }

  Future<void> _startNavigation() async {
    setState(() {
      _error = null;
    });

    try {
      await _navigationService.startNavigation();
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
    }
  }

  Future<void> _stopNavigation() async {
    await _navigationService.stopNavigation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _initialized && _mapOptions != null
                ? MapBoxNavigationView(
                    options: _mapOptions!,
                    onRouteEvent: (event) async {
                      await _navigationService.handleRouteEvent(event);
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    onCreated: (controller) {
                      _navigationService.attachViewController(controller);
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DashboardPreviewCard(state: _previewState),
                const SizedBox(height: 12),
                DropdownButtonFormField<NavigationDestination>(
                  value: _selectedDestination,
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                    border: OutlineInputBorder(),
                  ),
                  items: NavigationDestination.presets
                      .map(
                        (destination) => DropdownMenuItem(
                          value: destination,
                          child: Text(destination.name),
                        ),
                      )
                      .toList(),
                  onChanged: _navigationService.isNavigating
                      ? null
                      : (destination) {
                          if (destination == null) {
                            return;
                          }
                          setState(() {
                            _selectedDestination = destination;
                          });
                        },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Simulate route'),
                  subtitle: const Text('Useful for desk testing without moving'),
                  value: _simulateRoute,
                  onChanged: _navigationService.isNavigating
                      ? null
                      : (value) {
                          setState(() {
                            _simulateRoute = value;
                          });
                          _prepareNavigation();
                        },
                ),
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _buildingRoute || _navigationService.isNavigating
                            ? null
                            : _buildRoute,
                        child: Text(_buildingRoute ? 'Building...' : 'Build route'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _navigationService.routeBuilt &&
                                !_navigationService.isNavigating
                            ? _startNavigation
                            : null,
                        child: const Text('Start navigation'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed:
                      _navigationService.isNavigating ? _stopNavigation : null,
                  child: const Text('Stop navigation'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
