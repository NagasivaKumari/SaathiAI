import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<dynamic> alerts = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchAlerts();
  }

  Future<void> fetchAlerts() async {
    setState(() { loading = true; error = null; });
    try {
      final res = await http.get(Uri.parse('http://localhost:3000/api/alerts'));
      if (res.statusCode == 200) {
        alerts = json.decode(res.body);
      } else {
        error = 'Failed to load alerts';
      }
    } catch (e) {
      error = 'Network error';
    }
    setState(() { loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications & Alerts')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: TextStyle(color: Colors.red)))
              : ListView.builder(
                  itemCount: alerts.length,
                  itemBuilder: (context, idx) {
                    final alert = alerts[idx];
                    return ListTile(
                      leading: Icon(alert['read'] == true ? Icons.notifications_none : Icons.notifications_active, color: alert['read'] == true ? Colors.grey : Colors.red),
                      title: Text(alert['message'] ?? ''),
                      trailing: alert['read'] == true ? null : Icon(Icons.fiber_new, color: Colors.red),
                    );
                  },
                ),
    );
  }
}
