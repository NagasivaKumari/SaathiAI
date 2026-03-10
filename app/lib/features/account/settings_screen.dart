import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          ListTile(title: Text('Notifications'), onTap: () {}),
          ListTile(title: Text('Language'), onTap: () {}),
          ListTile(title: Text('Theme'), onTap: () {}),
          ListTile(title: Text('Privacy'), onTap: () {}),
        ],
      ),
    );
  }
}
