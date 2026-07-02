import 'dart:async';

import 'package:mapbox_navigation_sdk/mapbox_navigation_sdk.dart';

import '../models/navigation_progress.dart';

/// Preset destination for phone-side navigation testing.
class NavigationDestination {
  const NavigationDestination({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;

  WayPoint toWayPoint() => WayPoint(
        name: name,
        latitude: latitude,
        longitude: longitude,
      );

  static const List<NavigationDestination> presets = [
    NavigationDestination(
      id: 'buffalo_city_hall',
      name: 'Buffalo City Hall',
      latitude: 42.886448,
      longitude: -78.878372,
    ),
    NavigationDestination(
      id: 'downtown_buffalo',
      name: 'Downtown Buffalo',
      latitude: 42.8866177,
      longitude: -78.8814924,
    ),
    NavigationDestination(
      id: 'canalside',
      name: 'Canalside Buffalo',
      latitude: 42.8769,
      longitude: -78.8794,
    ),
  ];
}

/// Wraps Mapbox turn-by-turn navigation and exposes normalized progress events.
class NavigationService {
  NavigationService() : _navigation = MapBoxNavigation.instance;

  final MapBoxNavigation _navigation;
  final StreamController<NavigationProgress> _progressController =
      StreamController<NavigationProgress>.broadcast();

  MapBoxNavigationViewController? _viewController;
  NavigationProgress _progress = NavigationProgress.idle;
  bool _routeBuilt = false;
  bool _isNavigating = false;

  Stream<NavigationProgress> get progress => _progressController.stream;
  NavigationProgress get latestProgress => _progress;
  bool get routeBuilt => _routeBuilt;
  bool get isNavigating => _isNavigating;

  void attachViewController(MapBoxNavigationViewController controller) {
    _viewController = controller;
  }

  Future<void> initialize({
    required double initialLatitude,
    required double initialLongitude,
    bool simulateRoute = false,
  }) async {
    _navigation.setDefaultOptions(
      MapBoxOptions(
        initialLatitude: initialLatitude,
        initialLongitude: initialLongitude,
        zoom: 14,
        tilt: 0,
        bearing: 0,
        alternatives: true,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: true,
        mode: MapBoxNavigationMode.drivingWithTraffic,
        units: VoiceUnits.imperial,
        simulateRoute: simulateRoute,
        language: 'en',
      ),
    );

    // Route events are delivered via MapBoxNavigationView.onRouteEvent.
  }

  Future<void> buildRoute({
    required WayPoint origin,
    required WayPoint destination,
  }) async {
    final controller = _viewController;
    if (controller == null) {
      throw StateError('Navigation view is not ready');
    }

    await controller.buildRoute(
      wayPoints: [origin, destination],
    );
  }

  Future<void> startNavigation() async {
    final controller = _viewController;
    if (controller == null) {
      throw StateError('Navigation view is not ready');
    }

    await controller.startNavigation();
  }

  Future<void> stopNavigation() async {
    final controller = _viewController;
    if (controller != null) {
      await controller.finishNavigation();
    } else {
      await _navigation.finishNavigation();
    }

    _routeBuilt = false;
    _isNavigating = false;
    _setProgress(NavigationProgress.idle);
  }

  Future<void> handleRouteEvent(RouteEvent event) async {
    switch (event.eventType) {
      case MapBoxEvent.route_building:
        break;
      case MapBoxEvent.route_built:
        _routeBuilt = true;
        break;
      case MapBoxEvent.route_build_failed:
        _routeBuilt = false;
        break;
      case MapBoxEvent.navigation_running:
        _isNavigating = true;
        _setProgress(_progress.copyWith(active: true));
        break;
      case MapBoxEvent.progress_change:
        final data = event.data;
        if (data is RouteProgressEvent) {
          final distanceRemaining = await _navigation.getDistanceRemaining();
          final durationRemaining = await _navigation.getDurationRemaining();
          final instruction = data.currentStepInstruction;
          _setProgress(
            NavigationProgress(
              active: true,
              instruction: instruction,
              streetName: _extractStreetName(instruction, data.currentLeg?.name),
              distanceMeters: data.distance ?? distanceRemaining,
              etaMinutes: _minutesFromSeconds(durationRemaining ?? data.duration),
              maneuver: _parseManeuver(instruction),
              arrived: data.arrived ?? false,
            ),
          );
        }
        break;
      case MapBoxEvent.on_arrival:
        _setProgress(_progress.copyWith(active: false, arrived: true));
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        _routeBuilt = false;
        _isNavigating = false;
        _setProgress(NavigationProgress.idle);
        break;
      default:
        break;
    }
  }

  void _setProgress(NavigationProgress progress) {
    _progress = progress;
    _progressController.add(progress);
  }

  static int? _minutesFromSeconds(double? seconds) {
    if (seconds == null || seconds <= 0) {
      return null;
    }
    return (seconds / 60).ceil();
  }

  static String? _parseManeuver(String? instruction) {
    if (instruction == null || instruction.isEmpty) {
      return null;
    }

    final lower = instruction.toLowerCase();
    if (lower.contains('u-turn')) {
      return 'u-turn';
    }
    if (lower.contains('slight left')) {
      return 'slight-left';
    }
    if (lower.contains('slight right')) {
      return 'slight-right';
    }
    if (lower.contains('roundabout')) {
      return 'roundabout';
    }
    if (lower.contains('merge')) {
      return 'merge';
    }
    if (lower.contains('arrive')) {
      return 'arrive';
    }
    if (lower.contains('left')) {
      return 'left';
    }
    if (lower.contains('right')) {
      return 'right';
    }
    if (lower.contains('straight') || lower.contains('continue')) {
      return 'straight';
    }
    return 'straight';
  }

  static String? _extractStreetName(String? instruction, String? legName) {
    if (legName != null && legName.isNotEmpty) {
      return legName;
    }
    if (instruction == null) {
      return null;
    }

    final ontoMatch = RegExp(r'\bonto\s+(.+)$', caseSensitive: false).firstMatch(instruction);
    if (ontoMatch != null) {
      return ontoMatch.group(1)?.trim();
    }

    final towardMatch =
        RegExp(r'\btoward\s+(.+)$', caseSensitive: false).firstMatch(instruction);
    if (towardMatch != null) {
      return towardMatch.group(1)?.trim();
    }

    return null;
  }

  void dispose() {
    _progressController.close();
  }
}
