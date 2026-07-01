import 'dart:async';

import '../models/dashboard_state.dart';
import 'dashboard_state_builder.dart';

/// BLE transport layer for sending dashboard state to the ESP32 display.
///
/// TODO: integrate flutter_blue_plus — scan, connect, write to GATT characteristic.
class BleService {
  bool isConnected = false;

  Timer? _mockTimer;

  void startMockStream(DashboardState initialState) {
    stopMockStream();
    _mockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Placeholder: will write DashboardStateBuilder.encode(state) over BLE.
      DashboardStateBuilder.encode(initialState);
    });
  }

  void stopMockStream() {
    _mockTimer?.cancel();
    _mockTimer = null;
  }

  void dispose() {
    stopMockStream();
  }
}
