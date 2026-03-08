import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {'msg': 'PM-Kisan registration deadline in 3 days', 'isRead': false},
      {'msg': 'Tomato price increased by 12%', 'isRead': false},
      {'msg': 'New skill training available near you', 'isRead': true},
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear all',
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, idx) {
          final n = notifications[idx];
          final bool isRead = n['isRead'] == true;
          final String msg = n['msg']?.toString() ?? '';
          return ListTile(
            leading: Icon(isRead ? Icons.notifications_none : Icons.notifications_active, color: Colors.green),
            title: Text(msg, style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
            trailing: IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Mark as read',
              onPressed: () {},
            ),
          );
        },
      ),
    );
  }
}
