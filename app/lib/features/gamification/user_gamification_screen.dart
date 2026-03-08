import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserGamificationScreen extends StatefulWidget {
  final String userId;
  const UserGamificationScreen({super.key, required this.userId});

  @override
  State<UserGamificationScreen> createState() => _UserGamificationScreenState();
}

class _UserGamificationScreenState extends State<UserGamificationScreen> {
  Map<String, dynamic>? userData;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() { loading = true; error = null; });
    try {
      final res = await http.get(Uri.parse('http://localhost:3000/api/gamification/user/${widget.userId}'));
      if (res.statusCode == 200) {
        userData = json.decode(res.body);
      } else {
        error = 'Failed to load user data';
      }
    } catch (e) {
      error = 'Network error';
    }
    setState(() { loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Gamification')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: TextStyle(color: Colors.red)))
              : userData == null
                  ? Center(child: Text('No data'))
                  : Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Points: ${userData!['points'] ?? 0}', style: TextStyle(fontSize: 20)),
                          Text('Level: ${userData!['level'] ?? 1}', style: TextStyle(fontSize: 20)),
                          Text('Streak: ${userData!['streak'] ?? 0} days', style: TextStyle(fontSize: 20)),
                          const SizedBox(height: 16),
                          if ((userData!['milestone'] ?? false))
                            Card(
                              color: Colors.yellow.shade100,
                              child: ListTile(
                                leading: Icon(Icons.emoji_events, color: Colors.orange, size: 32),
                                title: Text('Congratulations!', style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('You reached a new milestone!'),
                              ),
                            ),
                          if ((userData!['streak'] ?? 0) > 5)
                            Card(
                              color: Colors.green.shade100,
                              child: ListTile(
                                leading: Icon(Icons.local_fire_department, color: Colors.red, size: 32),
                                title: Text('Streak Celebration!'),
                                subtitle: Text('You have a ${userData!['streak']} day streak! Keep going!'),
                              ),
                            ),
                          if ((userData!['points'] ?? 0) > 1000)
                            Card(
                              color: Colors.blue.shade100,
                              child: ListTile(
                                leading: Icon(Icons.star, color: Colors.blue, size: 32),
                                title: Text('Superstar!'),
                                subtitle: Text('You crossed 1000 points!'),
                              ),
                            ),
                        ],
                      ),
                    ),
    );
  }
}
