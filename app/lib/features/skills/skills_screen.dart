import 'package:flutter/material.dart';
import '../../core/config.dart';
import '../../services/api_client.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  List<dynamic> skills = _fallbackSkills;
  bool loading = false;
  String? error;
  late final ApiClient api;

  @override
  void initState() {
    super.initState();
    api = ApiClient(baseUrl: AppConfig.BASE_URL);
    // Show fallback data immediately, then try to fetch real data
    Future.microtask(() => fetchSkills());
  }

  static List<Map<String, dynamic>> get _fallbackSkills => [
    {'id': '1', 'name': 'Organic Farming', 'category': 'Agriculture', 'description': 'Learn sustainable farming', 'progress': 0.7, 'duration': '3 weeks', 'certificate': true, 'status': 'In Progress'},
    {'id': '2', 'name': 'Dairy Management', 'category': 'Agriculture', 'description': 'Cow care basics', 'progress': 1.0, 'duration': '2 weeks', 'certificate': true, 'status': 'Completed'},
    {'id': '3', 'name': 'Digital Literacy', 'category': 'Digital', 'description': 'Using apps for market', 'progress': 0.2, 'duration': '1 week', 'certificate': false, 'status': 'In Progress'},
  ];

  Future<void> fetchSkills() async {
    setState(() { error = null; });
    try {
      skills = await api.getSkills();
    } catch (_) {
      skills = _fallbackSkills;
    }
    if (mounted) setState(() { loading = false; });
  }

  IconData _skillIcon(String name) {
    if (name.contains('Farming')) return Icons.eco;
    if (name.contains('Dairy')) return Icons.local_drink;
    if (name.contains('Digital')) return Icons.phone_android;
    return Icons.school;
  }

  @override
  Widget build(BuildContext context) {
    // Always show at least fallback/demo data
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
