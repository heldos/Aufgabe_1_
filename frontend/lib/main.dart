import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';

import 'gen/tempconv/v1/tempconv.pbgrpc.dart';

void main() {
  runApp(const TempConvApp());
}

class TempConvApp extends StatelessWidget {
  const TempConvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TempConv',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const TempConvHome(),
    );
  }
}

class TempConvHome extends StatefulWidget {
  const TempConvHome({super.key});

  @override
  State<TempConvHome> createState() => _TempConvHomeState();
}

class _TempConvHomeState extends State<TempConvHome> {
  final _endpointCtrl = TextEditingController(text: 'localhost:50051');
  final _celsiusCtrl = TextEditingController();
  final _fahrenheitCtrl = TextEditingController();

  String? _status;

  Future<TempConvServiceClient> _client() async {
    final parts = _endpointCtrl.text.trim().split(':');
    final host = parts.first;
    final port = parts.length > 1 ? int.tryParse(parts[1]) ?? 50051 : 50051;

    final channel = ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );

    return TempConvServiceClient(channel);
  }

  Future<void> _convertC2F() async {
    final c = double.tryParse(_celsiusCtrl.text.trim());
    if (c == null) {
      setState(() => _status = 'Please enter a valid Celsius value.');
      return;
    }

    setState(() => _status = 'Converting…');
    try {
      final client = await _client();
      final res = await client.celsiusToFahrenheit(
        CelsiusToFahrenheitRequest()..celsius = c,
        options: CallOptions(timeout: const Duration(seconds: 3)),
      );
      setState(() {
        _fahrenheitCtrl.text = res.fahrenheit.toStringAsFixed(2);
        _status = null;
      });
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  Future<void> _convertF2C() async {
    final f = double.tryParse(_fahrenheitCtrl.text.trim());
    if (f == null) {
      setState(() => _status = 'Please enter a valid Fahrenheit value.');
      return;
    }

    setState(() => _status = 'Converting…');
    try {
      final client = await _client();
      final res = await client.fahrenheitToCelsius(
        FahrenheitToCelsiusRequest()..fahrenheit = f,
        options: CallOptions(timeout: const Duration(seconds: 3)),
      );
      setState(() {
        _celsiusCtrl.text = res.celsius.toStringAsFixed(2);
        _status = null;
      });
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  @override
  void dispose() {
    _endpointCtrl.dispose();
    _celsiusCtrl.dispose();
    _fahrenheitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TempConv')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _endpointCtrl,
              decoration: const InputDecoration(
                labelText: 'Backend endpoint (host:port)',
                hintText: 'localhost:50051',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _celsiusCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Celsius'),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _convertC2F,
                  child: const Text('C → F'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fahrenheitCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Fahrenheit'),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _convertF2C,
                  child: const Text('F → C'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_status != null)
              Text(
                _status!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 12),
            const Text(
              'Tip: On Android emulator use 10.0.2.2:50051 to reach your host.',
            ),
          ],
        ),
      ),
    );
  }
}

