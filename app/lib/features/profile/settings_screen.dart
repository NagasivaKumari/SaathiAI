import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings'), backgroundColor: Colors.green),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const ListTile(
            leading: Icon(Icons.person),
            title: Text('Name'),
            subtitle: Text('Ramesh'),
          ),
          const ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Village'),
            subtitle: Text('Nalgonda'),
          ),
          const ListTile(
            leading: Icon(Icons.work),
            title: Text('Occupation'),
            subtitle: Text('Farmer'),
          ),
          const ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            subtitle: Text('Hindi'),
          ),
          const Divider(),
          SwitchListTile(
            value: true,
            onChanged: (v) {},
            title: const Text('Voice Assistance'),
          ),
          SwitchListTile(
            value: true,
            onChanged: (v) {},
            title: const Text('Notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Offline Sync'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
