import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Base URL for the backend API.
/// Local dev: backend on localhost:8080. Production: same origin + /api (ingress routes /api -> backend).
String get apiBaseUrl {
  final base = Uri.base;
  if (base.host == 'localhost' || base.host == '127.0.0.1') {
    return 'http://localhost:8080';
  }
  return '${base.origin}/api';
}

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _celsiusController = TextEditingController();
  final _fahrenheitController = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _celsiusController.dispose();
    _fahrenheitController.dispose();
    super.dispose();
  }

  Future<void> _celsiusToFahrenheit() async {
    final value = double.tryParse(_celsiusController.text);
    if (value == null) {
      setState(() => _error = 'Enter a valid number');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      final uri = Uri.parse('$apiBaseUrl/celsius-to-fahrenheit').replace(
        queryParameters: {'value': value.toString()},
      );
      final resp = await http.get(uri);
      if (resp.statusCode != 200) {
        throw Exception('${resp.statusCode}: ${resp.body}');
      }
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final result = (data['value'] as num).toDouble();
      setState(() {
        _fahrenheitController.text = result.toStringAsFixed(2);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _fahrenheitToCelsius() async {
    final value = double.tryParse(_fahrenheitController.text);
    if (value == null) {
      setState(() => _error = 'Enter a valid number');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      final uri = Uri.parse('$apiBaseUrl/fahrenheit-to-celsius').replace(
        queryParameters: {'value': value.toString()},
      );
      final resp = await http.get(uri);
      if (resp.statusCode != 200) {
        throw Exception('${resp.statusCode}: ${resp.body}');
      }
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final result = (data['value'] as num).toDouble();
      setState(() {
        _celsiusController.text = result.toStringAsFixed(2);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature Converter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _celsiusController,
                  decoration: const InputDecoration(
                    labelText: 'Celsius',
                    border: OutlineInputBorder(),
                    suffixText: '°C',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  onSubmitted: (_) => _celsiusToFahrenheit(),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _loading ? null : _celsiusToFahrenheit,
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_downward),
                  label: const Text('Celsius → Fahrenheit'),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _fahrenheitController,
                  decoration: const InputDecoration(
                    labelText: 'Fahrenheit',
                    border: OutlineInputBorder(),
                    suffixText: '°F',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  onSubmitted: (_) => _fahrenheitToCelsius(),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _loading ? null : _fahrenheitToCelsius,
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text('Fahrenheit → Celsius'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
