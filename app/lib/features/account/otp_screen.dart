import 'package:flutter/material.dart';

class OTPScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OTP Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: 'Enter OTP')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
