import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SchemeDetailScreen extends StatefulWidget {
  final String schemeId;
  const SchemeDetailScreen({super.key, required this.schemeId});

  @override
  State<SchemeDetailScreen> createState() => _SchemeDetailScreenState();
}

class _SchemeDetailScreenState extends State<SchemeDetailScreen> {
  Map<String, dynamic>? scheme;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchSchemeDetail();
  }

  Future<void> fetchSchemeDetail() async {
    setState(() { loading = true; error = null; });
    try {
      final res = await http.get(Uri.parse('http://localhost:3000/api/schemes/${widget.schemeId}'));
      if (res.statusCode == 200) {
        scheme = json.decode(res.body);
      } else {
        error = 'Failed to load scheme details';
      }
    } catch (e) {
      error = 'Network error';
    }
    setState(() { loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Scheme Details')),
        body: Center(child: Text(error!, style: TextStyle(color: Colors.red))),
      );
    }
    if (scheme == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Scheme Details')),
        body: Center(child: Text('Scheme not found')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(scheme!['name'] ?? 'Scheme Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(scheme!['name'] ?? '', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(scheme!['description'] ?? '', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text('Benefit:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(scheme!['benefit'] ?? ''),
            SizedBox(height: 16),
            Text('Eligibility:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...List<Widget>.from((scheme!['eligibility'] ?? []).map((e) => Text('- $e'))),
            SizedBox(height: 16),
            Text('Documents:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...List<Widget>.from((scheme!['documents'] ?? []).map((d) => Text('- $d'))),
            SizedBox(height: 16),
            Text('Application Process:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...List<Widget>.from((scheme!['application_process'] ?? []).map((step) => Text('- $step'))),
            SizedBox(height: 16),
            Text('Common Rejections:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...List<Widget>.from((scheme!['common_rejections'] ?? []).map((r) => Text('- $r'))),
            SizedBox(height: 16),
            Text('Helpline:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(scheme!['helpline'] ?? ''),
            SizedBox(height: 8),
            Text('Website:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(scheme!['website'] ?? '', style: TextStyle(color: Colors.blue)),
            SizedBox(height: 16),
            Text('Important Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...List<Widget>.from((scheme!['important_notes'] ?? []).map((n) => Text('- $n'))),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                // Demo: use a static userId
                final userId = 'demoUser';
                final schemeId = scheme!['id'];
                final applicationData = {'name': scheme!['name']};
                final res = await http.post(
                  Uri.parse('http://localhost:3000/api/schemes/apply'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode({
                    'userId': userId,
                    'schemeId': schemeId,
                    'applicationData': applicationData,
                  }),
                );
                String msg;
                if (res.statusCode == 200) {
                  final resp = json.decode(res.body);
                  msg = resp['message'] ?? 'Application submitted';
                } else {
                  msg = 'Failed to apply';
                }
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Application Status'),
                    content: Text(msg),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Apply Now'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final userId = 'demoUser';
                final schemeId = scheme!['id'];
                final res = await http.get(
                  Uri.parse('http://localhost:3000/api/schemes/application-status?userId=$userId&schemeId=$schemeId'),
                );
                String msg;
                if (res.statusCode == 200) {
                  final resp = json.decode(res.body);
                  msg = 'Status: ${resp['status']}';
                } else {
                  msg = 'No application found';
                }
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Application Status'),
                    content: Text(msg),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Check Application Status'),
            ),
          ],
        ),
      ),
    );
  }
}
