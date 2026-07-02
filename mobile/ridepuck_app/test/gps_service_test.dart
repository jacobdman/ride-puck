import 'package:flutter_test/flutter_test.dart';
import 'package:ridepuck_app/services/gps_service.dart';

void main() {
  test('meters per second converts to miles per hour', () {
    expect(GpsService.metersPerSecondToMilesPerHour(0), 0);
    expect(GpsService.metersPerSecondToMilesPerHour(10), closeTo(22.3694, 0.001));
    expect(GpsService.metersPerSecondToMilesPerHour(-1), 0);
  });
}
