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

  @override
  void dispose() {
    _bleService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ScoutOS')),
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
            const Spacer(),
            FilledButton(
              onPressed: _toggleMockStream,
              child: Text(_sendingMock ? 'Stop mock data' : 'Send mock dashboard state'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                // TODO: scan and connect to ScoutOS display peripheral
              },
              child: const Text('Connect to display'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleMockStream() {
    setState(() {
      _sendingMock = !_sendingMock;
    });

    if (_sendingMock) {
      _bleService.startMockStream(DashboardStateBuilder.mockRide());
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
