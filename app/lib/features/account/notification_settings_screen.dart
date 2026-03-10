import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notification Settings')),
      body: SwitchListTile(
        value: true,
        onChanged: (v) {},
        title: Text('Enable Notifications'),
      ),
    );
  }
}
