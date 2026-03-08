import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamificationStreaks extends StatefulWidget {
  const GamificationStreaks({super.key});

  @override
  State<GamificationStreaks> createState() => _GamificationStreaksState();
}

class _GamificationStreaksState extends State<GamificationStreaks> {
  int streak = 0;
  int milestone = 0;
  bool showCelebration = false;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      streak = prefs.getInt('streak') ?? 0;
      milestone = (streak ~/ 5) * 5;
      showCelebration = streak > 0 && streak % 5 == 0;
    });
  }

  Future<void> incrementStreak() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      streak++;
      milestone = (streak ~/ 5) * 5;
      showCelebration = streak > 0 && streak % 5 == 0;
    });
    await prefs.setInt('streak', streak);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Current Streak: $streak days', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (milestone > 0)
          Text('Milestone: $milestone days!', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        if (showCelebration)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(Icons.emoji_events, color: Colors.amber, size: 48),
          ),
        ElevatedButton(
          onPressed: incrementStreak,
          child: Text('Log Today\'s Activity'),
        ),
      ],
    );
  }
}
