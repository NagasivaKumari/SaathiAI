import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config.dart';
import '../schemes/schemes_screen.dart';
import '../market/market_screen.dart';
import '../skills/skills_screen.dart';

/// Stitch design tokens from stitch_sathiai_village_dashboard
class _Design {
  static const primary = Color(0xFF4CDF20);
  static const backgroundLight = Color(0xFFF6F8F6);
  static const textPrimary = Color(0xFF131711);
  static const textMuted = Color(0xFF6C8764);
}

class VillageDashboardScreen extends StatefulWidget {
  const VillageDashboardScreen({super.key});

  @override
  State<VillageDashboardScreen> createState() => _VillageDashboardScreenState();
}

class _VillageDashboardScreenState extends State<VillageDashboardScreen> {
  Map<String, dynamic>? dashboard;
  List<dynamic> recentUpdates = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _loadRecentUpdates();
  }

  Future<void> _loadDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('userEmail');
      if (email == null || email.isEmpty) {
        setState(() {
          dashboard = {
            'user': {'name': 'Ramesh Ji', 'nextPayout': '15th Oct', 'nextScheme': 'PM Kisan'},
            'points': 750,
            'level': 12,
            'badge': 'Gold Badge',
          };
          loading = false;
        });
        return;
      }
      final res = await http.get(
        Uri.parse('${AppConfig.BASE_URL}/api/user/dashboard?email=$email'),
        headers: {'ngrok-skip-browser-warning': '69420'},
      );
      if (res.statusCode == 200 && mounted) {
        dashboard = json.decode(res.body);
        setState(() {});
      } else {
        setState(() {
          dashboard = {
            'user': {'name': 'Ramesh Ji', 'nextPayout': '15th Oct', 'nextScheme': 'PM Kisan'},
            'points': 750,
            'level': 12,
            'badge': 'Gold Badge',
          };
        });
      }
    } catch (_) {
      setState(() {
        dashboard = {
          'user': {'name': 'Ramesh Ji', 'nextPayout': '15th Oct', 'nextScheme': 'PM Kisan'},
          'points': 750,
          'level': 12,
          'badge': 'Gold Badge',
        };
      });
    }
    setState(() => loading = false);
  }

  void _loadRecentUpdates() {
    recentUpdates = [
      {'type': 'weather', 'title': 'Weather Alert', 'body': 'Light rain expected in your area tomorrow afternoon.', 'time': '2 hours ago'},
      {'type': 'scheme', 'title': 'Scheme Update', 'body': 'PM-Kisan 15th installment released. Check your status.', 'time': '5 hours ago'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: _Design.backgroundLight,
        body: Center(child: CircularProgressIndicator(color: _Design.primary)),
      );
    }
    final user = dashboard?['user'] ?? {};
    final userName = user['name'] ?? 'Ramesh Ji';
    final points = dashboard?['points'] ?? user['points'] ?? 750;
    final level = dashboard?['level'] ?? user['level'] ?? 12;
    final badge = dashboard?['badge'] ?? 'Gold Badge';

    return Scaffold(
      backgroundColor: _Design.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('SathiAI', style: TextStyle(color: _Design.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: _Design.primary.withOpacity(0.2),
            child: const Icon(Icons.eco, color: _Design.primary, size: 24),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: _Design.textPrimary),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildProfileHeader(userName),
              _buildGamificationCard(points: points, level: level, badge: badge),
              _buildSathiInsightCard(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text('How can I help you today?', style: TextStyle(color: _Design.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              _buildQuickAccessCards(context),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Text('Recent Updates', style: TextStyle(color: _Design.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              _buildRecentUpdates(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String userName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: _Design.primary.withOpacity(0.2),
            child: const Icon(Icons.person, size: 40, color: _Design.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Namaste, $userName', style: const TextStyle(color: _Design.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Aapka Sathi aapki madad ke liye taiyar hai.', style: TextStyle(color: _Design.textMuted, fontSize: 14)),
                const Text('Sab thik chal raha hai?', style: TextStyle(color: _Design.textMuted, fontSize: 13, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamificationCard({required int points, required int level, required String badge}) {
    const maxXp = 1000;
    final progress = (points / maxXp).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _Design.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _Design.primary.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sakhi Learner Level', style: TextStyle(color: _Design.textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
                    Text(badge, style: const TextStyle(color: _Design.primary, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                  child: const Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Daily Progress', style: TextStyle(color: _Design.textPrimary, fontSize: 16, fontWeight: FontWeight.w500)),
                Text('$points / $maxXp XP', style: const TextStyle(color: _Design.primary, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: progress, minHeight: 12, backgroundColor: Colors.grey.shade200, valueColor: const AlwaysStoppedAnimation(_Design.primary)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.trending_up, size: 16, color: _Design.textMuted),
                const SizedBox(width: 4),
                Text('${maxXp - points} XP more to reach next level', style: const TextStyle(color: _Design.textMuted, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSathiInsightCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _Design.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: _Design.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.lightbulb, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Tomato prices in Azadpur Mandi are expected to rise by 15% next week. Wait 4 days before selling for maximum profit.',
                    style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
              child: const Text('Sathi Advice', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCards(BuildContext context) {
    final items = [
      {'icon': Icons.account_balance, 'title': 'Government Schemes', 'subtitle': 'Find support and subsidies for you', 'color': Colors.blue, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SchemesScreen()))},
      {'icon': Icons.menu_book, 'title': 'Skill Learning', 'subtitle': 'New techniques for better farming', 'color': Colors.orange, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SkillsScreen()))},
      {'icon': Icons.storefront, 'title': 'Market Prices', 'subtitle': 'Check latest Mandi rates', 'color': Colors.green, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketScreen()))},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: items.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: e['onTap'] as void Function()?,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(color: (e['color'] as Color).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                        child: Icon(e['icon'] as IconData, size: 28, color: e['color'] as Color),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e['title'] as String, style: const TextStyle(color: _Design.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(e['subtitle'] as String, style: const TextStyle(color: _Design.textMuted, fontSize: 14)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: _Design.textMuted),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentUpdates() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: recentUpdates.length,
        itemBuilder: (context, i) {
          final u = recentUpdates[i];
          final isWeather = u['type'] == 'weather';
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(isWeather ? Icons.cloud : Icons.payments, size: 18, color: isWeather ? _Design.primary : Colors.blue),
                    const SizedBox(width: 8),
                    Text(u['title'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isWeather ? _Design.primary : Colors.blue)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(u['body'] as String, style: const TextStyle(color: _Design.textPrimary, fontWeight: FontWeight.w500)),
                const Spacer(),
                Text(u['time'] as String, style: const TextStyle(fontSize: 12, color: _Design.textMuted)),
              ],
            ),
          );
        },
      ),
    );
  }
}
