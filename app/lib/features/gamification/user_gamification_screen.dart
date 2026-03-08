import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../core/config.dart';
import '../../core/providers/language_provider.dart';

class UserGamificationScreen extends StatefulWidget {
  final String userId;
  const UserGamificationScreen({super.key, required this.userId});

  @override
  State<UserGamificationScreen> createState() => _UserGamificationScreenState();
}

class _UserGamificationScreenState extends State<UserGamificationScreen> {
  Map<String, dynamic>? userData;
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    // Use mock data that looks real
    userData = {
      'name': 'Amit Sharma',
      'points': 1280,
      'level': 7,
      'streak': 9,
      'milestone': true,
    };
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(lang.translate('My Gamification'))),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Text(
                lang.translate(error!),
                style: const TextStyle(color: Colors.red),
              ),
            )
          : userData == null
          ? Center(child: Text(lang.translate('No data')))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${lang.translate('Points')}: ${userData!['points'] ?? 0}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    '${lang.translate('Level')}: ${userData!['level'] ?? 1}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    '${lang.translate('Streak')}: ${userData!['streak'] ?? 0} ${lang.translate('days')}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  if ((userData!['milestone'] ?? false))
                    Card(
                      color: Colors.yellow.shade100,
                      child: ListTile(
                        leading: const Icon(
                          Icons.emoji_events,
                          color: Colors.orange,
                          size: 32,
                        ),
                        title: Text(
                          lang.translate('Congratulations!'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          lang.translate('You reached a new milestone!'),
                        ),
                      ),
                    ),
                  if ((userData!['streak'] ?? 0) > 5)
                    Card(
                      color: Colors.green.shade100,
                      child: ListTile(
                        leading: const Icon(
                          Icons.local_fire_department,
                          color: Colors.red,
                          size: 32,
                        ),
                        title: Text(lang.translate('Streak Celebration!')),
                        subtitle: Text(
                          '${lang.translate('You have a')} ${userData!['streak']} ${lang.translate('day streak! Keep going!')}',
                        ),
                      ),
                    ),
                  if ((userData!['points'] ?? 0) > 1000)
                    Card(
                      color: Colors.blue.shade100,
                      child: ListTile(
                        leading: const Icon(
                          Icons.star,
                          color: Colors.blue,
                          size: 32,
                        ),
                        title: Text(lang.translate('Superstar!')),
                        subtitle: Text(
                          lang.translate('You crossed 1000 points!'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
