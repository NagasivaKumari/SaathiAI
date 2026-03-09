

import 'package:flutter/material.dart';
import '../../core/config.dart';
import '../../services/api_client.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> notifications = [];
  bool loading = true;
  String? error;
  late final ApiClient api;

  @override
  void initState() {
    super.initState();
    api = ApiClient(baseUrl: AppConfig.BASE_URL);
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    setState(() { loading = true; error = null; });
    try {
      notifications = await api.getNotifications();
    } catch (e) {
      error = 'Network error';
    }
    setState(() { loading = false; });
  }

  @override
  Widget build(BuildContext context) {
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
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  separatorBuilder: (_, _) => const Divider(),
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
