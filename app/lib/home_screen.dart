import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Color(0xFF219653),
        elevation: 0,
        title: Text('SathiAI', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: Icon(Icons.person, color: Colors.green[800]),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 32, backgroundColor: Colors.green[200], child: Icon(Icons.person, size: 40, color: Colors.white)),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hi, Sunil, Sanchi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                        SizedBox(height: 4),
                        Text('Next payout: 3 Days', style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                        Text('Next scheme: 4:30 PM', style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text('Quick Access', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _QuickAccessItem(icon: Icons.mic, label: 'Ask Sathi'),
                  _QuickAccessItem(icon: Icons.school, label: 'Skills'),
                  _QuickAccessItem(icon: Icons.account_balance, label: 'Schemes'),
                  _QuickAccessItem(icon: Icons.shopping_basket, label: 'Market'),
                ],
              ),
              SizedBox(height: 28),
              Text('My Badges', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _BadgeCard(title: 'Gold Badge', subtitle: 'Scheme Seeker', icon: Icons.emoji_events, color: Colors.amber)),
                  SizedBox(width: 12),
                  Expanded(child: _BadgeCard(title: 'Skill Starter', subtitle: 'Started a skill', icon: Icons.star, color: Colors.orange)),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        backgroundColor: Color(0xFFF8FFF6),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: ''),
        ],
      ),
    );
  }
}

class _QuickAccessItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickAccessItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.green[50],
          radius: 28,
          child: Icon(icon, color: Colors.green, size: 32),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 15, color: Colors.black)),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _BadgeCard({required this.title, required this.subtitle, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 36),
          SizedBox(height: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }
}
