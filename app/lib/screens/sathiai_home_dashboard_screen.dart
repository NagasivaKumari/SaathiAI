import 'package:flutter/material.dart';
import '../widgets/language_selector.dart';
import '../services/api_client.dart';
import '../services/voice_service.dart';
import '../services/local_db_service.dart';
import '../core/config.dart';

class SathiAIHomeDashboardScreen extends StatefulWidget {
  const SathiAIHomeDashboardScreen({super.key});

  @override
  State<SathiAIHomeDashboardScreen> createState() =>
      _SathiAIHomeDashboardScreenState();
}

class _SathiAIHomeDashboardScreenState
    extends State<SathiAIHomeDashboardScreen> {
  String _selectedLang = 'en';
  final List<String> _supportedLangs = ['en', 'hi', 'te'];
  final ApiClient _apiClient = ApiClient(
    baseUrl: AppConfig.BASE_URL,
  ); // Update baseUrl as needed
  bool _syncing = false;
  String _syncStatus = '';

  Future<void> _syncOfflineData() async {
    setState(() {
      _syncing = true;
      _syncStatus = 'Syncing...';
    });
    try {
      final schemes = await _apiClient.getSchemesBulk(lang: _selectedLang);
      final skills = await _apiClient.getSkillsBulk(lang: _selectedLang);
      final market = await _apiClient.getMarketBulk(lang: _selectedLang);
      await LocalDatabaseService.cachePredictiveRecommendations({
        'schemes': schemes,
        'skills': skills,
        'market': market,
      });
      setState(() {
        _syncStatus = 'Offline data synced!';
      });
    } catch (e) {
      setState(() {
        _syncStatus = 'Sync failed: $e';
      });
    } finally {
      setState(() {
        _syncing = false;
      });
    }
  }

  void _speakDemo() {
    VoiceService.speak('Welcome to SathiAI!', _selectedLang);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SathiAI Home Dashboard')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LanguageSelector(
            selectedLang: _selectedLang,
            supportedLangs: _supportedLangs,
            onChanged: (lang) {
              setState(() {
                _selectedLang = lang;
              });
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _syncing ? null : _syncOfflineData,
            child: Text(_syncing ? 'Syncing...' : 'Sync Offline Data'),
          ),
          if (_syncStatus.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(_syncStatus),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _speakDemo,
            child: const Text('Speak Welcome (Demo)'),
          ),
        ],
      ),
    );
  }
}
