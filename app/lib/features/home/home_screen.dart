import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String userName = 'Sunil, Sanchi';
    final String nextPayout = '3 Days';
    final String nextScheme = '4:30 PM';
    final List<Map<String, dynamic>> badges = [
      {'icon': Icons.emoji_events, 'label': 'Gold Badge', 'desc': 'Scheme Seeker'},
      {'icon': Icons.star, 'label': 'Skill Starter', 'desc': 'Started a skill'},
    ];

    return Scaffold(
      backgroundColor: Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Color(0xFF219653),
        elevation: 0,
        title: Text('SathiAI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            tooltip: 'Profile & Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.green.shade200,
                  child: const Icon(Icons.person, size: 36, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hi, $userName', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Next payout: $nextPayout', style: const TextStyle(color: Colors.grey)),
                      Text('Next scheme: $nextScheme', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: Icon(Icons.check_circle, color: Colors.blue),
                title: Text("Today's Action", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Apply for PM Kisan scheme today!'),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {},
                  child: Text('Apply'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.green.shade50,
                    child: ListTile(
                      leading: Icon(Icons.trending_up, color: Colors.green),
                      title: Text('Market: Price Rise', style: TextStyle(color: Colors.green)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    color: Colors.red.shade50,
                    child: ListTile(
                      leading: Icon(Icons.warning, color: Colors.red),
                      title: Text('Deadline: 2 days', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.yellow.shade50,
              child: ListTile(
                leading: Icon(Icons.notifications, color: Colors.yellow.shade700),
                title: Text('New Notification'),
                subtitle: Text('Scheme payout credited!'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.grey.shade200,
              child: ListTile(
                leading: Icon(Icons.sync, color: Colors.blueGrey),
                title: Text('Sync Status'),
                subtitle: Text('Last synced: Today 10:30 AM'),
              ),
            ),
            const SizedBox(height: 24),
            const Text('My Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: badges.length,
                separatorBuilder: (context, idx) => const SizedBox(width: 16),
                itemBuilder: (context, idx) {
                  final badge = badges[idx];
                  return Container(
                    width: 120,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade50,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(badge['icon'], color: Colors.amber, size: 32),
                        const SizedBox(height: 8),
                        Text(badge['label'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(badge['desc'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
