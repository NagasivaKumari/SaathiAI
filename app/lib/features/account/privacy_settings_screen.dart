import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Privacy Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            value: true,
            onChanged: (v) {},
            title: Text('Allow Data Sharing'),
          ),
          SwitchListTile(
            value: false,
            onChanged: (v) {},
            title: Text('Allow Personalized Ads'),
          ),
        ],
      ),
    );
  }
}
