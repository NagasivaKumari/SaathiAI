import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AchievementsBadgesScreen extends StatefulWidget {
  const AchievementsBadgesScreen({super.key});

  @override
  State<AchievementsBadgesScreen> createState() => _AchievementsBadgesScreenState();
}

class _AchievementsBadgesScreenState extends State<AchievementsBadgesScreen> {
  List<dynamic> leaderboard = [];
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    setState(() { loading = true; error = ''; });
    try {
      final res = await http.get(Uri.parse('https://f47f-2405-201-c033-282b-98d-a46-df4e-a61.ngrok-free.app/api/gamification/leaderboard'));
      if (res.statusCode == 200) {
        leaderboard = json.decode(res.body);
      } else {
        error = 'Failed to load leaderboard';
      }
    } catch (e) {
      error = 'Network error';
    }
    setState(() { loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leaderboard')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error, style: TextStyle(color: Colors.red)))
              : ListView.builder(
                  itemCount: leaderboard.length,
                  itemBuilder: (context, idx) {
                    final user = leaderboard[idx];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${idx + 1}')),
                      title: Text(user['name'] ?? 'User'),
                      subtitle: Text('Points: ${user['points'] ?? 0}'),
                    );
                  },
                ),
    );
  }
}
