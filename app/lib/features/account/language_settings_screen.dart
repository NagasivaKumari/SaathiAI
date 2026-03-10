import 'package:flutter/material.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Language Settings')),
      body: ListView(
        children: [
          ListTile(title: Text('English'), onTap: () {}),
          ListTile(title: Text('Hindi'), onTap: () {}),
        ],
      ),
    );
  }
}
