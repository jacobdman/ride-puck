import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Live GPS position and speed for phone-side testing and navigation.
class GpsService {
  static const double metersPerSecondToMph = 2.23694;

  StreamSubscription<Position>? _subscription;
  final StreamController<GpsSnapshot> _controller =
      StreamController<GpsSnapshot>.broadcast();

  GpsSnapshot _latest = GpsSnapshot.unavailable();
  String? _error;

  Stream<GpsSnapshot> get snapshots => _controller.stream;
  GpsSnapshot get latest => _latest;
  String? get error => _error;

  static double metersPerSecondToMilesPerHour(double metersPerSecond) {
    if (metersPerSecond < 0) {
      return 0;
    }
    return metersPerSecond * metersPerSecondToMph;
  }

  Future<bool> requestPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  Future<bool> ensureReady() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setError('Location services are disabled');
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      _setError('Location permission denied');
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      _setError('Location permission permanently denied');
      return false;
    }

    _error = null;
    return true;
  }

  Future<void> start() async {
    await stop();

    if (!await ensureReady()) {
      return;
    }

    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 2,
    );

    _subscription = Geolocator.getPositionStream(locationSettings: settings).listen(
      (position) {
        _latest = GpsSnapshot.fromPosition(position);
        _error = null;
        _controller.add(_latest);
      },
      onError: (Object error) {
        _setError(error.toString());
      },
    );
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    stop();
    _controller.close();
  }

  void _setError(String message) {
    _error = message;
    _latest = GpsSnapshot.unavailable();
    _controller.add(_latest);
  }
}

class GpsSnapshot {
  const GpsSnapshot({
    required this.available,
    required this.speedMph,
    this.headingDeg,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
  });

  final bool available;
  final double speedMph;
  final double? headingDeg;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;

  factory GpsSnapshot.unavailable() {
    return const GpsSnapshot(available: false, speedMph: 0);
  }

  factory GpsSnapshot.fromPosition(Position position) {
    final speedMph = GpsService.metersPerSecondToMilesPerHour(position.speed);
    return GpsSnapshot(
      available: true,
      speedMph: speedMph,
      headingDeg: position.heading >= 0 ? position.heading : null,
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
    );
  }

  String get gpsSignal {
    if (!available || accuracyMeters == null) {
      return 'none';
    }
    if (accuracyMeters! <= 10) {
      return 'good';
    }
    if (accuracyMeters! <= 30) {
      return 'fair';
    }
    return 'poor';
  }
}
