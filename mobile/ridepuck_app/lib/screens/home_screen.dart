import 'package:flutter/material.dart';

import '../config/mapbox_config.dart';
import '../screens/navigation_screen.dart';
import '../services/ble_service.dart';
import '../services/gps_service.dart';

/// Entry screen — connection status and phone-side test controls.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BleService _bleService = BleService();
  final GpsService _gpsService = GpsService();

  bool _sendingMock = false;
  bool _connecting = false;
  String? _statusMessage;
  GpsSnapshot _gps = GpsSnapshot.unavailable();
  String? _gpsError;

  @override
  void initState() {
    super.initState();
    _bleService.connectionState.listen((connected) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (!connected) {
          _sendingMock = false;
        }
        _statusMessage = connected ? 'Connected to RidePuck display' : null;
      });
    });
    _startGps();
  }

  Future<void> _startGps() async {
    await _gpsService.start();
    _gpsService.snapshots.listen((snapshot) {
      if (!mounted) {
        return;
      }
      setState(() {
        _gps = snapshot;
        _gpsError = _gpsService.error;
      });
    });
    if (mounted) {
      setState(() {
        _gps = _gpsService.latest;
        _gpsError = _gpsService.error;
      });
    }
  }

  @override
  void dispose() {
    _bleService.dispose();
    _gpsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gpsStatus = _gps.available
        ? '${_gps.speedMph.round()} MPH'
        : (_gpsError ?? 'Waiting for GPS');

    return Scaffold(
      appBar: AppBar(title: const Text('RidePuck')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Motorcycle dashboard companion',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            _StatusCard(label: 'GPS', value: gpsStatus),
            const SizedBox(height: 12),
            _StatusCard(label: 'Mapbox', value: MapboxConfig.statusLabel),
            const SizedBox(height: 12),
            _StatusCard(
              label: 'BLE',
              value: _bleService.isConnected ? 'Connected' : 'Disconnected',
            ),
            const SizedBox(height: 8),
            Text(
              'BLE requires RidePuck display hardware.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _statusMessage!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (_bleService.lastError != null) ...[
              const SizedBox(height: 12),
              Text(
                _bleService.lastError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const Spacer(),
            FilledButton(
              onPressed: MapboxConfig.isConfigured
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => NavigationScreen(gpsService: _gpsService),
                        ),
                      );
                    }
                  : null,
              child: const Text('Start navigation'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: _bleService.isConnected && !_connecting ? _toggleMockStream : null,
              child: Text(_sendingMock ? 'Stop mock data' : 'Send mock dashboard state'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _connecting ? null : _toggleConnection,
              child: Text(
                _connecting
                    ? 'Connecting...'
                    : _bleService.isConnected
                        ? 'Disconnect'
                        : 'Connect to display',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleConnection() async {
    if (_bleService.isConnected) {
      await _bleService.disconnect();
      setState(() {
        _sendingMock = false;
        _statusMessage = null;
      });
      return;
    }

    setState(() {
      _connecting = true;
      _statusMessage = 'Scanning for RidePuck...';
    });

    try {
      await _bleService.connect();
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = 'Connected to RidePuck display';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _connecting = false;
        });
      }
    }
  }

  void _toggleMockStream() {
    setState(() {
      _sendingMock = !_sendingMock;
    });

    if (_sendingMock) {
      _bleService.startMockStream();
    } else {
      _bleService.stopMockStream();
    }
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
