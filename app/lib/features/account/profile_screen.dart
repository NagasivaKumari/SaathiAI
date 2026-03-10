import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder profile data
    final profile = {
      'name': 'John Doe',
      'email': 'john@example.com',
      'phone': '+1234567890',
      'photoUrl': null,
    };
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: profile['photoUrl'] != null ? NetworkImage(profile['photoUrl']) : null,
                child: profile['photoUrl'] == null ? Icon(Icons.person, size: 40) : null,
              ),
            ),
            SizedBox(height: 20),
            Text('Name: ${profile['name']}'),
            Text('Email: ${profile['email']}'),
            Text('Phone: ${profile['phone']}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text('Edit Profile'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}
