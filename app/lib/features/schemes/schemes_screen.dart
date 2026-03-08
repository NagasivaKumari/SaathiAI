
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'scheme_detail_screen.dart';

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  List<dynamic> schemes = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchSchemes();
  }

  Future<void> fetchSchemes() async {
    setState(() { loading = true; error = null; });
    try {
      final res = await http.get(Uri.parse('http://localhost:3000/api/schemes'));
      if (res.statusCode == 200) {
        schemes = json.decode(res.body);
      } else {
        error = 'Failed to load schemes';
      }
    } catch (e) {
      error = 'Network error';
    }
    setState(() { loading = false; });
  }

  Color _statusColor(String status) {
    if (status == 'Active') return Colors.green.shade100;
    if (status == 'Apply Soon') return Colors.yellow.shade100;
    return Colors.red.shade100;
  }

  IconData _statusIcon(String name) {
    if (name.contains('Kisan')) return Icons.agriculture;
    if (name.contains('Awas')) return Icons.home;
    if (name.contains('Bima')) return Icons.grass;
    return Icons.account_balance;
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
        body: Center(child: Text(error!, style: TextStyle(color: Colors.red))),
      );
    }
    return Scaffold(
      backgroundColor: Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Schemes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Discover Government Schemes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: schemes.length,
                separatorBuilder: (context, idx) => SizedBox(height: 16),
                itemBuilder: (context, idx) {
                  final scheme = schemes[idx];
                  return Card(
                    color: _statusColor(scheme['status'] ?? 'Active'),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: Icon(_statusIcon(scheme['name'] ?? ''), color: Colors.green, size: 36),
                      title: Text(scheme['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(scheme['description'] ?? ''),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(scheme['status'] ?? 'Active',
                              style: TextStyle(
                                color: (scheme['status'] ?? 'Active') == 'Active'
                                    ? Colors.green
                                    : (scheme['status'] ?? '') == 'Apply Soon'
                                        ? Colors.orange
                                        : Colors.red,
                                fontWeight: FontWeight.bold,
                              )),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (scheme['status'] ?? 'Active') == 'Active'
                                  ? Colors.green
                                  : (scheme['status'] ?? '') == 'Apply Soon'
                                      ? Colors.orange
                                      : Colors.grey,
                              minimumSize: Size(80, 32),
                            ),
                            onPressed: (scheme['status'] ?? 'Active') == 'Active'
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SchemeDetailScreen(schemeId: scheme['id']),
                                      ),
                                    );
                                  }
                                : null,
                            child: Text((scheme['status'] ?? 'Active') == 'Active'
                                ? 'View'
                                : (scheme['status'] ?? '') == 'Apply Soon'
                                    ? 'Notify Me'
                                    : 'Closed'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
