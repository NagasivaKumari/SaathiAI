import 'package:flutter/material.dart';

class AchievementsBadgesScreen extends StatelessWidget {
  const AchievementsBadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6F6),
        elevation: 0,
        title: Text(
          'Achievements',
          style: TextStyle(
            color: Color(0xFF221610),
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'Public Sans',
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Achievements & Badges UI goes here',
          style: TextStyle(fontSize: 18, color: Color(0xFF221610)),
        ),
      ),
    );
  }
}
