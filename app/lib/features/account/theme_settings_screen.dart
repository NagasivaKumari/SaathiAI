import 'package:flutter/material.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Theme Settings')),
      body: ListView(
        children: [
          ListTile(title: Text('Light'), onTap: () {}),
          ListTile(title: Text('Dark'), onTap: () {}),
        ],
      ),
    );
  }
}
