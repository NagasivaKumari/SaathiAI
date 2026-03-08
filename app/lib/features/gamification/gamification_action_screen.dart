import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GamificationActionScreen extends StatefulWidget {
  const GamificationActionScreen({super.key});

  @override
  State<GamificationActionScreen> createState() => _GamificationActionScreenState();
}

class _GamificationActionScreenState extends State<GamificationActionScreen> {
  String? result;
  bool loading = false;

  Future<void> awardPoints(String action) async {
    setState(() { loading = true; result = null; });
    try {
      final res = await http.post(
        Uri.parse('http://localhost:3000/api/gamification/action'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': action}),
      );
      if (res.statusCode == 200) {
        result = 'Points awarded!';
      } else {
        result = 'Failed to award points';
      }
    } catch (e) {
      result = 'Network error';
    }
    setState(() { loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Award Points')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: loading ? null : () => awardPoints('view_scheme'),
              child: Text('Award for Viewing Scheme'),
            ),
            ElevatedButton(
              onPressed: loading ? null : () => awardPoints('ai_query'),
              child: Text('Award for AI Query'),
            ),
            if (loading) CircularProgressIndicator(),
            if (result != null) Text(result!, style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
