import 'package:flutter/material.dart';

class VoiceScreen extends StatelessWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Ask Saathi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade100,
              ),
              child: Icon(Icons.mic, color: Colors.green, size: 64),
            ),
            SizedBox(height: 24),
            Text('Tap the mic and ask your question',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(160, 48),
              ),
              icon: Icon(Icons.mic, color: Colors.white),
              label: Text('Start Listening', style: TextStyle(color: Colors.white)),
              onPressed: () {},
            ),
            SizedBox(height: 32),
            Text('Transcript will appear here...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
