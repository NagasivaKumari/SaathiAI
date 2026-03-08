import 'package:flutter/material.dart';

import 'features/schemes/schemes_screen.dart';
import 'features/market/market_screen.dart';
import 'features/skills/skills_screen.dart';
import 'features/voice/voice_screen.dart';
import 'features/profile/profile_screen.dart';






// --- Data Models ---
class Scheme {
  final String name;
  final String description;
  final bool applied;
  Scheme({required this.name, required this.description, this.applied = false});
}

class Skill {
  final String name;
  final String status;
  Skill({required this.name, required this.status});
}

class UserProgress {
  final int schemesApplied;
  final int skillsCompleted;
  final int badgesEarned;
  UserProgress({required this.schemesApplied, required this.skillsCompleted, required this.badgesEarned});
}

class Badge {
  final String name;
  final String description;
  final bool earned;
  Badge({required this.name, required this.description, this.earned = false});
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    SchemesScreen(),
    MarketScreen(),
    SkillsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: _buildMicButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildMicButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 800),
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.2),
              ),
            ),
            FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => VoiceScreen()));
              },
              tooltip: 'Ask Saathi',
              elevation: 6,
              shape: CircleBorder(),
              child: Icon(Icons.mic, color: Colors.white, size: 32),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('Ask Saathi', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabIcon(Icons.home, 'Home', 0),
          _buildTabIcon(Icons.search, 'Schemes', 1),
          const SizedBox(width: 48), // Space for mic
          _buildTabIcon(Icons.agriculture, 'Market', 2),
          _buildTabIcon(Icons.school, 'Skills', 3),
        ],
      ),
    );
  }

  Widget _buildTabIcon(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.green : Colors.grey, size: 28),
          Text(label, style: TextStyle(color: isSelected ? Colors.green : Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}

// --- Screen Stubs ---
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
            },
            tooltip: 'Profile & Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.green.shade200,
                  child: Icon(Icons.person, size: 36, color: Colors.white),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hi, $userName', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Next payout: $nextPayout', style: TextStyle(color: Colors.grey)),
                      Text('Next scheme: $nextScheme', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
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
            SizedBox(height: 16),
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
                SizedBox(width: 8),
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
            SizedBox(height: 16),
            Card(
              color: Colors.yellow.shade50,
              child: ListTile(
                leading: Icon(Icons.notifications, color: Colors.yellow.shade700),
                title: Text('New Notification'),
                subtitle: Text('Scheme payout credited!'),
              ),
            ),
            SizedBox(height: 16),
            Card(
              color: Colors.grey.shade200,
              child: ListTile(
                leading: Icon(Icons.sync, color: Colors.blueGrey),
                title: Text('Sync Status'),
                subtitle: Text('Last synced: Today 10:30 AM'),
              ),
            ),
            SizedBox(height: 24),
            Text('My Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: badges.length,
                separatorBuilder: (context, idx) => SizedBox(width: 16),
                itemBuilder: (context, idx) {
                  final badge = badges[idx];
                  return Container(
                    width: 120,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade50,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(badge['icon'], color: Colors.amber, size: 32),
                        SizedBox(height: 8),
                        Text(badge['label'], style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(badge['desc'], style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
class DashboardScreen extends StatelessWidget {
  final List<Scheme> schemes;
  final List<Skill> skills;
  final UserProgress progress;
  const DashboardScreen({super.key, required this.schemes, required this.skills, required this.progress});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dashboard, size: 40, color: Colors.blueGrey.shade700),
              const SizedBox(width: 12),
              const Text('Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Schemes Applied: ${progress.schemesApplied}', style: const TextStyle(fontSize: 16)),
          Text('Skills Completed: ${progress.skillsCompleted}', style: const TextStyle(fontSize: 16)),
          Text('Badges Earned: ${progress.badgesEarned}', style: const TextStyle(fontSize: 16)),
          const Divider(height: 32),
          const Text('Your Schemes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...schemes.map((s) => ListTile(
                leading: Icon(s.applied ? Icons.check_circle : Icons.circle_outlined, color: s.applied ? Colors.green : Colors.grey),
                title: Text(s.name),
                subtitle: Text(s.description),
                trailing: s.applied ? const Text('Applied', style: TextStyle(color: Colors.green)) : null,
              )),
          const Divider(height: 32),
          const Text('Your Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...skills.map((sk) => ListTile(
                leading: Icon(Icons.school, color: sk.status == 'Completed' ? Colors.green : Colors.orange),
                title: Text(sk.name),
                subtitle: Text('Status: ${sk.status}'),
              )),
        ],
      ),
    );
  }
}

class GamificationScreen extends StatelessWidget {
  final List<Badge> badges;
  final UserProgress progress;
  const GamificationScreen({super.key, required this.badges, required this.progress});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, size: 40, color: Colors.amber.shade700),
              const SizedBox(width: 12),
              const Text('Gamification', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Badges Earned: ${progress.badgesEarned}', style: const TextStyle(fontSize: 16)),
          const Divider(height: 32),
          const Text('Your Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...badges.map((b) => ListTile(
                leading: Icon(
                  b.earned ? Icons.emoji_events : Icons.emoji_events_outlined,
                  color: b.earned ? Colors.amber : Colors.grey,
                ),
                title: Text(b.name),
                subtitle: Text(b.description),
                trailing: b.earned ? const Text('Earned', style: TextStyle(color: Colors.amber)) : null,
              )),
        ],
      ),
    );
  }
}
