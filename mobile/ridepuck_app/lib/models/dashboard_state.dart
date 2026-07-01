/// Normalized dashboard state sent to the ESP32 display over BLE.
///
/// Schema: shared/dashboard-state.schema.json
class DashboardState {
  const DashboardState({
    required this.version,
    required this.timestamp,
    required this.ride,
    required this.navigation,
    this.device,
  });

  final int version;
  final int timestamp;
  final RideState ride;
  final NavigationState navigation;
  final DeviceState? device;

  Map<String, dynamic> toJson() => {
        'version': version,
        'timestamp': timestamp,
        'ride': ride.toJson(),
        'navigation': navigation.toJson(),
        if (device != null) 'device': device!.toJson(),
      };
}

class RideState {
  const RideState({required this.speedMph, this.headingDeg});

  final double speedMph;
  final double? headingDeg;

  Map<String, dynamic> toJson() => {
        'speedMph': speedMph,
        if (headingDeg != null) 'headingDeg': headingDeg,
      };
}

class NavigationState {
  const NavigationState({
    required this.active,
    this.maneuver,
    this.distanceMeters,
    this.instruction,
    this.streetName,
    this.etaMinutes,
  });

  final bool active;
  final String? maneuver;
  final double? distanceMeters;
  final String? instruction;
  final String? streetName;
  final int? etaMinutes;

  Map<String, dynamic> toJson() => {
        'active': active,
        if (maneuver != null) 'maneuver': maneuver,
        if (distanceMeters != null) 'distanceMeters': distanceMeters,
        if (instruction != null) 'instruction': instruction,
        if (streetName != null) 'streetName': streetName,
        if (etaMinutes != null) 'etaMinutes': etaMinutes,
      };
}

class DeviceState {
  const DeviceState({this.phoneBattery, this.gpsSignal});

  final int? phoneBattery;
  final String? gpsSignal;

  Map<String, dynamic> toJson() => {
        if (phoneBattery != null) 'phoneBattery': phoneBattery,
        if (gpsSignal != null) 'gpsSignal': gpsSignal,
      };
}
