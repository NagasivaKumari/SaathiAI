import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: 'OTP')),
            TextField(decoration: InputDecoration(labelText: 'New Password'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
