import 'package:flutter/material.dart';

import '../services/ble_service.dart';
import '../services/dashboard_state_builder.dart';

/// Entry screen — connection status and mock dashboard controls for desk testing.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BleService _bleService = BleService();
  bool _sendingMock = false;
  bool _connecting = false;
  String? _statusMessage;

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
  }

  @override
  void dispose() {
    _bleService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            _StatusCard(
              label: 'BLE',
              value: _bleService.isConnected ? 'Connected' : 'Disconnected',
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
            Text(value),
          ],
        ),
      ),
    );
  }
}
