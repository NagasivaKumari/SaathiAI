import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../core/config.dart';
import '../services/local_db_service.dart';

class SkillsScreen extends StatefulWidget {
  final String lang;
  final bool offline;
  const SkillsScreen({super.key, required this.lang, this.offline = false});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  late Future<List<dynamic>> _skillsFuture;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  void _loadSkills() {
    if (widget.offline) {
      _skillsFuture = LocalDatabaseService.getCachedSkills();
    } else {
      _skillsFuture = ApiClient(
        baseUrl: AppConfig.BASE_URL,
      ).getSkills(lang: widget.lang);
    }
  }

  @override
  void didUpdateWidget(covariant SkillsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lang != widget.lang || oldWidget.offline != widget.offline) {
      _loadSkills();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skill Programs')),
      body: FutureBuilder<List<dynamic>>(
        future: _skillsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final skills = snapshot.data ?? [];
          if (skills.isEmpty) {
            return const Center(child: Text('No skills found.'));
          }
          return ListView.builder(
            itemCount: skills.length,
            itemBuilder: (context, idx) {
              final s = skills[idx];
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
                          if (s['duration'] != null) ...[
                            const SizedBox(height: 8),
                            Text('Duration: ${s['duration']}'),
                          ],
                          if (s['certificate'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Certificate: ${s['certificate'] ? 'Yes' : 'No'}',
                            ),
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
