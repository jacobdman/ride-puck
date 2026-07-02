import 'package:flutter/material.dart';

import '../models/dashboard_state.dart';

/// Compact preview of what the round ESP32 display would show.
class DashboardPreviewCard extends StatelessWidget {
  const DashboardPreviewCard({
    super.key,
    required this.state,
  });

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final navigation = state.navigation;
    final ride = state.ride;

    return Card(
      color: const Color(0xFF1A1A1A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Display preview',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFFC41E3A),
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ride.speedMph.round().toString(),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 8),
                  child: Text(
                    'MPH',
                    style: TextStyle(color: Color(0xFFAAAAAA)),
                  ),
                ),
                const Spacer(),
                Icon(
                  _maneuverIcon(navigation.maneuver),
                  color: const Color(0xFFC41E3A),
                  size: 32,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              navigation.instruction ?? (navigation.active ? 'Navigating' : 'No route'),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              _distanceLabel(navigation.distanceMeters),
              style: const TextStyle(color: Colors.white70),
            ),
            if (navigation.streetName != null) ...[
              const SizedBox(height: 4),
              Text(
                navigation.streetName!,
                style: const TextStyle(color: Color(0xFFAAAAAA)),
              ),
            ],
            if (navigation.etaMinutes != null) ...[
              const SizedBox(height: 4),
              Text(
                'ETA ${navigation.etaMinutes} min',
                style: const TextStyle(color: Color(0xFFAAAAAA)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static IconData _maneuverIcon(String? maneuver) {
    switch (maneuver) {
      case 'left':
      case 'slight-left':
        return Icons.turn_left;
      case 'right':
      case 'slight-right':
        return Icons.turn_right;
      case 'u-turn':
        return Icons.u_turn_left;
      case 'arrive':
        return Icons.flag;
      case 'merge':
        return Icons.merge;
      case 'roundabout':
        return Icons.roundabout_left;
      default:
        return Icons.straight;
    }
  }

  static String _distanceLabel(double? meters) {
    if (meters == null) {
      return '--';
    }
    if (meters >= 1609) {
      return '${(meters / 1609).toStringAsFixed(1)} mi';
    }
    return '${(meters * 3.28084).round()} ft';
  }
}
