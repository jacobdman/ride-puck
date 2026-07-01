import 'dart:convert';

import '../models/dashboard_state.dart';

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

  static String encode(DashboardState state) => jsonEncode(state.toJson());
}
