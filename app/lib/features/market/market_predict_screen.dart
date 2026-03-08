import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MarketPredictScreen extends StatefulWidget {
  const MarketPredictScreen({super.key});

  @override
  State<MarketPredictScreen> createState() => _MarketPredictScreenState();
}

class _MarketPredictScreenState extends State<MarketPredictScreen> {
  String crop = '';
  Map<String, dynamic>? prediction;
  bool loading = false;
  String? error;

  Future<void> predict() async {
    setState(() { loading = true; error = null; prediction = null; });
    try {
      final res = await http.post(
        Uri.parse('http://localhost:3000/api/market/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'crop': crop}),
      );
      if (res.statusCode == 200) {
        prediction = json.decode(res.body);
      } else {
        error = 'Failed to get prediction';
      }
    } catch (e) {
      error = 'Network error';
    }
    setState(() { loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Market Price Prediction')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Crop Name'),
              onChanged: (v) => crop = v,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: loading ? null : predict,
              child: Text('Predict'),
            ),
            if (loading) CircularProgressIndicator(),
            if (error != null) Text(error!, style: TextStyle(color: Colors.red)),
            if (prediction != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Prediction: ${prediction!['forecast'] ?? ''}\nAdvice: ${prediction!['advice'] ?? ''}'),
              ),
          ],
        ),
      ),
    );
  }
}
