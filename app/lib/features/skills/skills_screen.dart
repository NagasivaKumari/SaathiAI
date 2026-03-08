import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  List<dynamic> skills = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchSkills();
  }

  Future<void> fetchSkills() async {
    setState(() { loading = true; error = null; });
    try {
      final res = await http.get(Uri.parse('http://localhost:3000/api/skills'));
      if (res.statusCode == 200) {
        skills = json.decode(res.body);
      } else {
        error = 'Failed to load skills';
      }
    } catch (e) {
      error = 'Network error';
    }
    setState(() { loading = false; });
  }

  IconData _skillIcon(String name) {
    if (name.contains('Farming')) return Icons.eco;
    if (name.contains('Dairy')) return Icons.local_drink;
    if (name.contains('Digital')) return Icons.phone_android;
    return Icons.school;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Scaffold(
        body: Center(child: Text(error!, style: TextStyle(color: Colors.red))),
      );
    }
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
                      leading: Icon(_skillIcon(skill['name'] ?? ''), color: Colors.green, size: 36),
                      title: Text(skill['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: (skill['progress'] ?? 0.0) * 1.0,
                            backgroundColor: Colors.grey.shade200,
                            color: Colors.green,
                            minHeight: 8,
                          ),
                          SizedBox(height: 6),
                          Text('Progress: ${((skill['progress'] ?? 0.0) * 100).toInt()}%'),
                        ],
                      ),
                      trailing: (skill['status'] ?? '') == 'Completed'
                          ? Icon(Icons.verified, color: Colors.blue)
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: Size(80, 32),
                              ),
                              onPressed: () {},
                              child: Text(skill['status'] ?? ''),
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
