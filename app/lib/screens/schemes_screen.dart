import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../core/config.dart';
import '../services/local_db_service.dart';

class SchemesScreen extends StatefulWidget {
  final String lang;
  final bool offline;
  const SchemesScreen({super.key, required this.lang, this.offline = false});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  late Future<List<dynamic>> _schemesFuture;

  @override
  void initState() {
    super.initState();
    _loadSchemes();
  }

  void _loadSchemes() {
    if (widget.offline) {
      _schemesFuture = LocalDatabaseService.getCachedSchemes();
    } else {
      _schemesFuture = ApiClient(
        baseUrl: AppConfig.BASE_URL,
      ).getSchemes(lang: widget.lang);
    }
  }

  @override
  void didUpdateWidget(covariant SchemesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lang != widget.lang || oldWidget.offline != widget.offline) {
      _loadSchemes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Government Schemes')),
      body: FutureBuilder<List<dynamic>>(
        future: _schemesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final schemes = snapshot.data ?? [];
          if (schemes.isEmpty) {
            return const Center(child: Text('No schemes found.'));
          }
          return ListView.builder(
            itemCount: schemes.length,
            itemBuilder: (context, idx) {
              final s = schemes[idx];
              return ListTile(
                title: Text(s['name'] ?? ''),
                subtitle: Text(s['description'] ?? ''),
                trailing: Text(s['category'] ?? ''),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(s['name'] ?? ''),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Description: ${s['description'] ?? ''}'),
                          const SizedBox(height: 8),
                          Text('Category: ${s['category'] ?? ''}'),
                          if (s['status'] != null) ...[
                            const SizedBox(height: 8),
                            Text('Status: ${s['status']}'),
                          ],
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
