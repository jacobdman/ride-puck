import 'package:flutter_test/flutter_test.dart';
import 'package:ridepuck_app/services/ble_service.dart';
import 'package:ridepuck_app/services/dashboard_state_builder.dart';

void main() {
  test('mock dashboard state matches v1 schema fields', () {
    final state = DashboardStateBuilder.mockRide();
    final json = state.toJson();

    expect(json['version'], 1);
    expect(json['ride']['speedMph'], 47);
    expect(json['navigation']['active'], isTrue);
    expect(json['navigation']['maneuver'], 'right');
    expect(json['device']['gpsSignal'], 'good');
  });

  test('encode produces valid JSON string', () {
    final encoded = DashboardStateBuilder.encode(DashboardStateBuilder.mockRide());
    expect(encoded, contains('"version":1'));
    expect(encoded, contains('"speedMph":47'));
  });

  test('BLE service uses protocol UUIDs', () {
    expect(
      BleService.serviceUuid.toString(),
      '0000fe00-0000-1000-8000-00805f9b34fb',
    );
    expect(
      BleService.dashboardCharUuid.toString(),
      '0000fe01-0000-1000-8000-00805f9b34fb',
    );
    expect(BleService.deviceName, 'RidePuck');
  });
}
