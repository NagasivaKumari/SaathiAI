import 'package:flutter/material.dart';

class SkillsScreen extends StatelessWidget {
  const SkillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> skills = [
      {
        'name': 'Organic Farming',
        'progress': 0.7,
        'status': 'Continue',
        'icon': Icons.eco,
      },
      {
        'name': 'Dairy Management',
        'progress': 1.0,
        'status': 'Completed',
        'icon': Icons.local_drink,
      },
      {
        'name': 'Digital Payments',
        'progress': 0.3,
        'status': 'Start',
        'icon': Icons.phone_android,
      },
    ];

    return Scaffold(
      backgroundColor: Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Skills', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Skill Training Center', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: skills.length,
                separatorBuilder: (context, idx) => SizedBox(height: 16),
                itemBuilder: (context, idx) {
                  final skill = skills[idx];
                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: Icon(skill['icon'], color: Colors.green, size: 36),
                      title: Text(skill['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: skill['progress'],
                            backgroundColor: Colors.grey.shade200,
                            color: Colors.green,
                            minHeight: 8,
                          ),
                          SizedBox(height: 6),
                          Text('Progress: ${(skill['progress'] * 100).toInt()}%'),
                        ],
                      ),
                      trailing: skill['status'] == 'Completed'
                          ? Icon(Icons.verified, color: Colors.blue)
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: Size(80, 32),
                              ),
                              onPressed: () {},
                              child: Text(skill['status']),
                            ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Card(
              color: Colors.amber.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: Icon(Icons.card_membership, color: Colors.amber),
                title: Text('Certificate Preview'),
                subtitle: Text('Complete a skill to earn certificate!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
