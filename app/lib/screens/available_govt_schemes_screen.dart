import 'package:flutter/material.dart';

class AvailableGovtSchemesScreen extends StatelessWidget {
  const AvailableGovtSchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final schemes = [
      {'name': 'PM-Kisan Samman Nidhi', 'desc': '₹6,000 yearly support for farmers.'},
      {'name': 'Ayushman Bharat', 'desc': 'Free health cover up to ₹5 Lakhs.'},
      {'name': 'PM Awas Yojana', 'desc': 'Housing for all in rural areas.'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Available Schemes')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: schemes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, idx) {
          final scheme = schemes[idx];
          return Card(
            child: ListTile(
              leading: Icon(Icons.account_balance_wallet, color: Colors.green),
              title: Text(scheme['name'] ?? ''),
              subtitle: Text(scheme['desc'] ?? ''),
            ),
          );
        },
      ),
    );
  }
}
