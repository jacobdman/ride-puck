import 'dart:convert';

import '../models/dashboard_state.dart';
import '../models/navigation_progress.dart';
import 'gps_service.dart';

/// Builds [DashboardState] payloads from GPS, Mapbox, or mock sources.
class DashboardStateBuilder {
  DashboardStateBuilder._();

  static DashboardState mockRide() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return DashboardState(
      version: 1,
      timestamp: now,
      ride: const RideState(speedMph: 47, headingDeg: 82),
      navigation: const NavigationState(
        active: true,
        maneuver: 'right',
        distanceMeters: 640,
        instruction: 'Turn right',
        streetName: 'Main St',
        etaMinutes: 14,
      ),
      device: const DeviceState(phoneBattery: 82, gpsSignal: 'good'),
    );
  }

  static DashboardState fromNavigation({
    required GpsSnapshot ride,
    required NavigationProgress progress,
    int? phoneBattery,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return DashboardState(
      version: 1,
      timestamp: now,
      ride: RideState(
        speedMph: ride.speedMph,
        headingDeg: ride.headingDeg,
      ),
      navigation: NavigationState(
        active: progress.active,
        maneuver: progress.maneuver,
        distanceMeters: progress.distanceMeters,
        instruction: progress.instruction,
        streetName: progress.streetName,
        etaMinutes: progress.etaMinutes,
      ),
      device: DeviceState(
        phoneBattery: phoneBattery,
        gpsSignal: ride.gpsSignal,
      ),
    );
  }

  static String encode(DashboardState state) => jsonEncode(state.toJson());
}
