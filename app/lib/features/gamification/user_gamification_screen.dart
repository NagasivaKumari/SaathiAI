import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/config.dart';
import '../../services/api_client.dart';

class UserGamificationScreen extends StatefulWidget {
  final String userId;
  const UserGamificationScreen({super.key, required this.userId});

  @override
  State<UserGamificationScreen> createState() => _UserGamificationScreenState();
}

class _UserGamificationScreenState extends State<UserGamificationScreen> {
  Map<String, dynamic>? userData;
  bool loading = true;
  String? error;
  late final ApiClient api;

  @override
  void initState() {
    super.initState();
    api = ApiClient(baseUrl: AppConfig.BASE_URL);
    fetchUserGamification();
  }

  Future<void> fetchUserGamification() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final res = await api._client.get(Uri.parse('${api.baseUrl}/api/gamification/user/${widget.userId}'));
      if (res.statusCode == 200) {
        userData = Map<String, dynamic>.from(jsonDecode(res.body));
      } else {
        error = 'Failed to load user data';
      }
    } catch (e) {
      error = 'Network error';
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(lang.translate('My Gamification'))),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Text(
                lang.translate(error!),
                style: const TextStyle(color: Colors.red),
              ),
            )
          : userData == null
          ? Center(child: Text(lang.translate('No data')))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${lang.translate('Points')}: ${userData!['points'] ?? 0}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    '${lang.translate('Level')}: ${userData!['level'] ?? 1}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    '${lang.translate('Streak')}: ${userData!['streak'] ?? 0} ${lang.translate('days')}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  if ((userData!['milestone'] ?? false))
                    Card(
                      color: Colors.yellow.shade100,
                      child: ListTile(
                        leading: const Icon(
                          Icons.emoji_events,
                          color: Colors.orange,
                          size: 32,
                        ),
                        title: Text(
                          lang.translate('Congratulations!'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          lang.translate('You reached a new milestone!'),
                        ),
                      ),
                    ),
                  if ((userData!['streak'] ?? 0) > 5)
                    Card(
                      color: Colors.green.shade100,
                      child: ListTile(
                        leading: const Icon(
                          Icons.local_fire_department,
                          color: Colors.red,
                          size: 32,
                        ),
                        title: Text(lang.translate('Streak Celebration!')),
                        subtitle: Text(
                          '${lang.translate('You have a')} ${userData!['streak']} ${lang.translate('day streak! Keep going!')}',
                        ),
                      ),
                    ),
                  if ((userData!['points'] ?? 0) > 1000)
                    Card(
                      color: Colors.blue.shade100,
                      child: ListTile(
                        leading: const Icon(
                          Icons.star,
                          color: Colors.blue,
                          size: 32,
                        ),
                        title: Text(lang.translate('Superstar!')),
                        subtitle: Text(
                          lang.translate('You crossed 1000 points!'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
