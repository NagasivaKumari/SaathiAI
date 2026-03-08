import 'package:flutter/material.dart';

class HomeDashboardWithAdviceNotificationScreen extends StatelessWidget {
  const HomeDashboardWithAdviceNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final advice = [
      {'title': 'Water your crops today', 'desc': 'Soil moisture is low. Irrigate your field.'},
      {'title': 'Market prices rising', 'desc': 'Tomato prices up 10% this week.'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Home Dashboard - Advice')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: advice.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, idx) {
          final a = advice[idx];
          return Card(
            child: ListTile(
              leading: Icon(Icons.notifications_active, color: Colors.orange),
              title: Text(a['title'] ?? ''),
              subtitle: Text(a['desc'] ?? ''),
            ),
          );
        },
      ),
    );
  }
}
