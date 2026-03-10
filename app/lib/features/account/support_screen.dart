import 'package:flutter/material.dart';

import 'contact_support_screen.dart';
import 'faq_screen.dart';
import 'report_problem_screen.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Support')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Contact Support'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ContactSupportScreen()),
            ),
          ),
          ListTile(
            title: Text('FAQ'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FAQScreen()),
            ),
          ),
          ListTile(
            title: Text('Report a Problem'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ReportProblemScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
