import 'package:flutter/material.dart';

class AchievementsBadges1Screen extends StatelessWidget {
  const AchievementsBadges1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Achievements')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Achievements',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _BadgeWidget(label: 'Gold', icon: Icons.emoji_events, color: Colors.amber),
                _BadgeWidget(label: 'Silver', icon: Icons.emoji_events, color: Colors.grey),
                _BadgeWidget(label: 'Bronze', icon: Icons.emoji_events, color: Colors.brown),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Recent Milestones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _MilestoneTile(title: 'Completed 10 tasks', date: 'March 2026'),
            _MilestoneTile(title: 'Helped 5 farmers', date: 'Feb 2026'),
            _MilestoneTile(title: 'Joined SathiAI', date: 'Jan 2026'),
          ],
        ),
      ),
    );
  }
}

class _BadgeWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _BadgeWidget({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  final String title;
  final String date;
  const _MilestoneTile({required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.check_circle, color: Colors.green),
      title: Text(title),
      subtitle: Text(date),
    );
  }
}
}
