import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/dashboard_state.dart';
import 'dashboard_state_builder.dart';

/// BLE transport layer for sending dashboard state to the ESP32 display.
class BleService {
  static final Guid serviceUuid = Guid('0000fe00-0000-1000-8000-00805f9b34fb');
  static final Guid dashboardCharUuid = Guid('0000fe01-0000-1000-8000-00805f9b34fb');

  static const String deviceName = 'RidePuck';
  static const Duration scanTimeout = Duration(seconds: 10);

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  BluetoothDevice? _device;
  BluetoothCharacteristic? _dashboardCharacteristic;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  Timer? _mockTimer;

  bool _isConnected = false;
  String? _lastError;

  bool get isConnected => _isConnected;
  String? get lastError => _lastError;
  Stream<bool> get connectionState => _connectionController.stream;

  Future<bool> requestPermissions() async {
    if (kIsWeb) {
      return true;
    }

    if (Platform.isAndroid) {
      final results = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();

      return results.values.every((status) => status.isGranted);
    }

    if (Platform.isIOS || Platform.isMacOS) {
      final status = await Permission.bluetooth.request();
      return status.isGranted;
    }

    return true;
  }

  Future<void> connect() async {
    _lastError = null;

    final granted = await requestPermissions();
    if (!granted) {
      _lastError = 'Bluetooth permissions denied';
      throw StateError(_lastError!);
    }

    if (await FlutterBluePlus.isSupported == false) {
      _lastError = 'Bluetooth not supported on this device';
      throw StateError(_lastError!);
    }

    await disconnect();

    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      _lastError = 'Bluetooth adapter is off';
      throw StateError(_lastError!);
    }

    BluetoothDevice? target;
    final scanCompleter = Completer<BluetoothDevice?>();
    late StreamSubscription<List<ScanResult>> scanSubscription;

    scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (scanCompleter.isCompleted) {
        return;
      }

      for (final result in results) {
        final name = result.device.platformName;
        if (name == deviceName || name.contains(deviceName)) {
          scanCompleter.complete(result.device);
          return;
        }
      }
    });

    await FlutterBluePlus.startScan(timeout: scanTimeout);

    try {
      target = await scanCompleter.future.timeout(
        scanTimeout,
        onTimeout: () => null,
      );
    } finally {
      await scanSubscription.cancel();
      await FlutterBluePlus.stopScan();
    }

    if (target == null) {
      _lastError = 'RidePuck display not found';
      throw StateError(_lastError!);
    }

    await target.connect(autoConnect: false, timeout: const Duration(seconds: 15));
    _device = target;

    _connectionSubscription = target.connectionState.listen((state) {
      final connected = state == BluetoothConnectionState.connected;
      _setConnected(connected);
    });

    await target.requestMtu(512);

    final services = await target.discoverServices();
    BluetoothCharacteristic? dashboardChar;

    for (final service in services) {
      if (service.uuid == serviceUuid) {
        for (final characteristic in service.characteristics) {
          if (characteristic.uuid == dashboardCharUuid) {
            dashboardChar = characteristic;
            break;
          }
        }
      }
    }

    if (dashboardChar == null) {
      _lastError = 'Dashboard characteristic not found';
      await disconnect();
      throw StateError(_lastError!);
    }

    _dashboardCharacteristic = dashboardChar;
    _setConnected(true);
  }

  Future<void> disconnect() async {
    stopMockStream();
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;

    if (_device != null) {
      try {
        await _device!.disconnect();
      } catch (_) {
        // Ignore disconnect errors during cleanup.
      }
    }

    _device = null;
    _dashboardCharacteristic = null;
    _setConnected(false);
  }

  Future<void> writeDashboardState(DashboardState state) async {
    final characteristic = _dashboardCharacteristic;
    if (characteristic == null || !_isConnected) {
      throw StateError('Not connected to RidePuck display');
    }

    final payload = DashboardStateBuilder.encode(state);
    final bytes = utf8.encode(payload);

    await characteristic.write(bytes, withoutResponse: true);
  }

  void startMockStream({DashboardState? initialState}) {
    stopMockStream();

    _mockTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!_isConnected) {
        return;
      }

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final base = initialState ?? DashboardStateBuilder.mockRide();
      final state = DashboardState(
        version: base.version,
        timestamp: now,
        ride: base.ride,
        navigation: base.navigation,
        device: base.device,
      );

      try {
        await writeDashboardState(state);
      } catch (error) {
        _lastError = error.toString();
      }
    });
  }

  void stopMockStream() {
    _mockTimer?.cancel();
    _mockTimer = null;
  }

  void dispose() {
    stopMockStream();
    _connectionController.close();
    disconnect();
  }

  void _setConnected(bool connected) {
    if (_isConnected == connected) {
      return;
    }
    _isConnected = connected;
    _connectionController.add(connected);
    if (!connected) {
      _dashboardCharacteristic = null;
    }
  }
}
