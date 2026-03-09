import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../core/config.dart';

class ProfileBadgesScreen extends StatefulWidget {
  final String userId;
  const ProfileBadgesScreen({super.key, required this.userId});

  @override
  State<ProfileBadgesScreen> createState() => _ProfileBadgesScreenState();
}

class _ProfileBadgesScreenState extends State<ProfileBadgesScreen> {
  late Future<Map<String, dynamic>> _gamificationFuture;

  @override
  void initState() {
    super.initState();
    _gamificationFuture = _fetchGamification();
  }

  Future<Map<String, dynamic>> _fetchGamification() async {
    // Replace with your actual API call
    final res = await ApiClient(
      baseUrl: AppConfig.BASE_URL,
    ).getGamification(widget.userId);
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Badges & Progress')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _gamificationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data ?? {};
          final badges = data['badges'] as List<dynamic>? ?? [];
          final points = data['points'] ?? 0;
          final level = data['level'] ?? 1;
          final streak = data['streak'] ?? 0;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Points: $points', style: const TextStyle(fontSize: 18)),
                Text('Level: $level', style: const TextStyle(fontSize: 18)),
                Text(
                  'Streak: $streak days',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Badges:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 12,
                  children: badges
                      .map((b) => Chip(label: Text(b.toString())))
                      .toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
