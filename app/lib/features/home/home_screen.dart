import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiClient api = ApiClient(baseUrl: 'http://10.0.2.2:8000');
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool searching = false;
  Map<String, dynamic>? dashboard = const {
    'user': {'name': 'Demo User', 'nextPayout': '15 Mar 2026', 'nextScheme': 'PM-Kisan'},
    'badges': [
      {'name': 'Starter', 'icon': '🏅'},
      {'name': 'Farmer', 'icon': '🌾'}
    ]
  };
  bool loading = false;
  String? error;
  List<dynamic> recommendations = const [
    {'title': 'Try Organic Farming', 'desc': 'Learn about organic methods for better yield.'},
    {'title': 'Check Market Prices', 'desc': 'Stay updated with latest mandi rates.'}
  ];

  final Map<String, Map<String, String>> localGreetings = {
    'en-US': {
      'greeting': 'Hi',
      'payout': 'Next payout',
      'recommendations': 'Proactive Recommendations',
    },
    'hi-IN': {
      'greeting': 'नमस्ते',
      'payout': 'अगला भुगतान',
      'recommendations': 'सुझाव',
    },
    'mr-IN': {
      'greeting': 'नमस्कार',
      'payout': 'पुढील पेमेंट',
      'recommendations': 'सूचना',
    },
    'bn-IN': {
      'greeting': 'নমস্কার',
      'payout': 'পরবর্তী পেমেন্ট',
      'recommendations': 'প্রস্তাবনা',
    },
  };
  String selectedLanguage = 'en-US';

  @override
  void initState() {
    super.initState();
    // Show demo data immediately, then try to fetch real data
    Future.microtask(() {
      fetchDashboard();
      fetchRecommendations();
    });
  }

  Future<void> doGlobalSearch(String query) async {
    if (query.trim().isEmpty) return;
    setState(() { searching = true; searchResults = []; });
    try {
      final results = await api.globalSearch(query, lang: selectedLanguage);
      setState(() { searchResults = results; });
    } catch (e) {
      setState(() { searchResults = []; });
    }
    setState(() { searching = false; });
  }

  Future<void> fetchDashboard() async {
    setState(() { error = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedDashboard = prefs.getString('dashboard');
      if (cachedDashboard != null) {
        dashboard = json.decode(cachedDashboard);
        setState(() { loading = false; });
      }
      final res = await http.get(Uri.parse('https://f47f-2405-201-c033-282b-98d-a46-df4e-a61.ngrok-free.app/api/user/dashboard'));
      if (res.statusCode == 200) {
        dashboard = json.decode(res.body);
        await prefs.setString('dashboard', res.body);
      } else {
        error = 'Failed to load dashboard';
      }
    } catch (e) {
      error = 'Network error';
    }
    setState(() { loading = false; });
  }

  Future<void> fetchRecommendations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedRecs = prefs.getString('recommendations');
      if (cachedRecs != null) {
        recommendations = json.decode(cachedRecs);
        setState(() {});
      }
      final res = await http.get(Uri.parse('https://f47f-2405-201-c033-282b-98d-a46-df4e-a61.ngrok-free.app/api/ai/predictive-recommendations?userId=demoUser&lang=en-US'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        recommendations = data['recommendations'] ?? [];
        await prefs.setString('recommendations', json.encode(recommendations));
        setState(() {});
      }
    } catch (e) {
      // ignore errors for now
    }
  }

  @override
  Widget build(BuildContext context) {
    // Always show at least demo data
    if (error != null) {
      return Scaffold(
        body: Center(child: Text(error!, style: TextStyle(color: Colors.red))),
      );
    }
    final user = dashboard?['user'] ?? {};
    final badges = dashboard?['badges'] ?? [];
    final userName = user['name'] ?? '';
    final nextPayout = user['nextPayout'] ?? '';
    final nextScheme = user['nextScheme'] ?? '';
    final greetings = localGreetings[selectedLanguage] ?? localGreetings['en-US']!;

    return Scaffold(
      backgroundColor: Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Color(0xFF219653),
        elevation: 0,
        title: Text('SathiAI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          DropdownButton<String>(
            value: selectedLanguage,
            dropdownColor: Colors.white,
            items: [
              DropdownMenuItem(value: 'en-US', child: Text('English')),
              DropdownMenuItem(value: 'hi-IN', child: Text('हिंदी')),
              DropdownMenuItem(value: 'mr-IN', child: Text('मराठी')),
              DropdownMenuItem(value: 'bn-IN', child: Text('বাংলা')),
            ],
            onChanged: (val) {
              setState(() { selectedLanguage = val ?? 'en-US'; });
            },
          ),
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
            // --- Search Bar ---
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search schemes, crop prices, skills...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: doGlobalSearch,
            ),
            const SizedBox(height: 12),
            if (searching) ...[
              Center(child: CircularProgressIndicator()),
              const SizedBox(height: 12),
            ],
            if (searchResults.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Search Results', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...searchResults.map((r) => Card(
                        child: ListTile(
                          leading: Icon(
                            r['type'] == 'scheme' ? Icons.account_balance :
                            r['type'] == 'skill' ? Icons.school :
                            r['type'] == 'market' ? Icons.shopping_basket :
                            Icons.search,
                            color: Colors.green,
                          ),
                          title: Text(r['name'] ?? r['crop'] ?? r['title'] ?? ''),
                          subtitle: Text(r['description'] ?? r['market'] ?? ''),
                        ),
                      )),
                  const SizedBox(height: 16),
                ],
              ),
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
                      Text('${greetings['greeting']}, $userName', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${greetings['payout']}: $nextPayout', style: const TextStyle(color: Colors.grey)),
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
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: badges.length,
                separatorBuilder: (context, idx) => const SizedBox(width: 16),
                itemBuilder: (context, idx) {
                  final badge = badges[idx];
                  return Container(
                    width: 110,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
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
                        Icon(badge['icon'], color: Colors.amber, size: 26),
                        const SizedBox(height: 4),
                        Text(badge['label'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(badge['desc'], style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.emoji_events),
                  label: Text('Leaderboard'),
                  onPressed: () => Navigator.pushNamed(context, '/leaderboard'),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.notifications),
                  label: Text('Alerts'),
                  onPressed: () => Navigator.pushNamed(context, '/alerts'),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.analytics),
                  label: Text('Predict'),
                  onPressed: () => Navigator.pushNamed(context, '/market-predict'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recommendations.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greetings['recommendations']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ...recommendations.map((rec) => Card(
                      child: ListTile(
                        leading: Icon(
                          rec['type'] == 'scheme' ? Icons.account_balance :
                          rec['type'] == 'skill' ? Icons.school :
                          rec['type'] == 'market' ? Icons.shopping_basket :
                          Icons.notifications,
                          color: Colors.green,
                        ),
                        title: Text(rec['message'] ?? ''),
                      ),
                    ))
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
