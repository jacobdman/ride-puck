/// Normalized navigation progress mapped from Mapbox route events.
class NavigationProgress {
  const NavigationProgress({
    required this.active,
    this.instruction,
    this.streetName,
    this.distanceMeters,
    this.etaMinutes,
    this.maneuver,
    this.arrived = false,
  });

  final bool active;
  final String? instruction;
  final String? streetName;
  final double? distanceMeters;
  final int? etaMinutes;
  final String? maneuver;
  final bool arrived;

  static const NavigationProgress idle = NavigationProgress(active: false);

  NavigationProgress copyWith({
    bool? active,
    String? instruction,
    String? streetName,
    double? distanceMeters,
    int? etaMinutes,
    String? maneuver,
    bool? arrived,
  }) {
    return NavigationProgress(
      active: active ?? this.active,
      instruction: instruction ?? this.instruction,
      streetName: streetName ?? this.streetName,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      maneuver: maneuver ?? this.maneuver,
      arrived: arrived ?? this.arrived,
    );
  }
}
