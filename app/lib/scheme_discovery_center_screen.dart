import 'package:flutter/material.dart';

class SchemeDiscoveryCenterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Scheme Discovery Center',
          style: TextStyle(
            color: Color(0xFF131711),
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'Lexend',
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Scheme Discovery Center UI goes here',
          style: TextStyle(fontSize: 18, color: Color(0xFF131711)),
        ),
      ),
    );
  }
}
