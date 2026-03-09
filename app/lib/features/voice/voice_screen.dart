// Removed unused import 'dart:io'
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../services/api_client.dart';
import '../../services/local_db_service.dart';
import '../../core/config.dart';
import 'package:voice_search/voice_search.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../services/audio_recorder_service.dart';
import '../../services/voice_service.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  bool isOffline = false;
  List<Map<String, dynamic>> cachedSchemes = [];
  List<Map<String, dynamic>> cachedMarket = [];
  List<Map<String, dynamic>> cachedSkills = [];
  Future<void> _loadOfflineData() async {
    cachedSchemes = await LocalDatabaseService.getCachedSchemes();
    cachedMarket = await LocalDatabaseService.getCachedMarket();
    cachedSkills = await LocalDatabaseService.getCachedSkills();
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // TODO: Replace with real connectivity check
    if (isOffline) {
      _loadOfflineData();
    }
  }

  // Removed unused field _recordedAudioFile
  final ApiClient api = ApiClient(baseUrl: AppConfig.BASE_URL);
  final TextEditingController _controller = TextEditingController();
  String transcript = '';
  String aiResponse = '';
  List<dynamic> searchResults = [];
  bool searching = false;
  bool loading = false;
  String selectedLanguage = 'en-US';
  final FlutterTts flutterTts = FlutterTts();
  late stt.SpeechToText speech;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
  }

  Future<void> _askAI() async {
    final query = transcript.isNotEmpty ? transcript : _controller.text.trim();
    if (query.isEmpty) return;
    setState(() {
      loading = true;
      aiResponse = '';
      searchResults = [];
      searching = true;
    });
    try {
      final results = await api.globalSearch(query, lang: selectedLanguage);
      setState(() {
        searchResults = results;
      });
      if (results.isEmpty) {
        setState(() {
          aiResponse = 'No results found.';
        });
      } else {
        setState(() {
          aiResponse = '';
        });
      }
    } catch (e) {
      setState(() {
        aiResponse = 'Network error';
      });
    }
    setState(() {
      loading = false;
      searching = false;
    });
  }

  void _onVoiceResult(String result) {
    setState(() {
      transcript = result;
      _controller.text = result;
    });
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage(selectedLanguage);
    await flutterTts.speak(text);
  }

  Future<void> _startListening() async {
    bool available = await speech.initialize();
    if (available) {
      setState(() => isListening = true);
      // Start audio recording for AWS Transcribe
      final dir = await getTemporaryDirectory();
      final audioPath = '${dir.path}/sathi_voice_input.m4a';
      await AudioRecorderService.startRecording(audioPath);
      speech.listen(
        onResult: (result) {
          setState(() {
            transcript = result.recognizedWords;
            _controller.text = transcript;
          });
        },
        localeId: selectedLanguage,
        listenFor: Duration(seconds: 10),
        onSoundLevelChange: null,
        cancelOnError: true,
        partialResults: true,
      );
    }
  }

  void _stopListening() async {
    await speech.stop();
    setState(() => isListening = false);
    // Stop audio recording and upload to backend for STT
    setState(() {
      loading = true;
    });
    final audioFile = await AudioRecorderService.stopRecording();
    if (audioFile != null) {
      final sttText = await VoiceService.transcribeAudio(
        audioFile,
        langCode: selectedLanguage,
      );
      if (sttText != null && sttText.isNotEmpty) {
        setState(() {
          transcript = sttText;
          _controller.text = sttText;
        });
      }
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Simulate offline detection (replace with real connectivity check if needed)
    // isOffline = ... (set based on connectivity)

    return Scaffold(
      backgroundColor: Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Ask Saathi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // AI Persona greeting
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8,
                ),
                child: Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.emoji_emotions,
                          color: Colors.green,
                          size: 32,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Namaste! Main aapka Sathi hoon. Apni bhasha mein kuch bhi poochhein—yahan schemes, skills, ya mandi ke daam sab milenge. (I am your village friend. Ask me anything in your language—schemes, skills, or market info!)',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Proactive suggestion
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Try asking: "Mere gaon mein kaun si sarkari yojana hai?" or "What skills can I learn for more income?"',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isOffline) ...[
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'You are offline. You can still access saved info below.',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (cachedSchemes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved Schemes:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        ...cachedSchemes.map(
                          (s) => Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.account_balance,
                                color: Colors.green,
                              ),
                              title: Text(s['name'] ?? ''),
                              subtitle: Text(s['description'] ?? ''),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (cachedMarket.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved Market Prices:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        ...cachedMarket.map(
                          (m) => Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.shopping_basket,
                                color: Colors.green,
                              ),
                              title: Text(m['crop'] ?? ''),
                              subtitle: Text(
                                '₹${m['price'] ?? ''} (${m['trend'] ?? ''})',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (cachedSkills.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved Skills:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        ...cachedSkills.map(
                          (sk) => Card(
                            child: ListTile(
                              leading: Icon(Icons.school, color: Colors.green),
                              title: Text(sk['name'] ?? ''),
                              subtitle: Text(sk['description'] ?? ''),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ] else ...[
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.shade100,
                  ),
                  child: Icon(Icons.mic, color: Colors.green, size: 64),
                ),
                SizedBox(height: 16),
                VoiceSearchWidget(
                  localeCode: selectedLanguage,
                  activeWidgetColor: Colors.green.shade200,
                  inactiveWidgetColor: Colors.green.shade100,
                  activeIcon: Icons.mic,
                  inactiveIcon: Icons.mic_none,
                  onResult: _onVoiceResult,
                ),
                SizedBox(height: 8),
                DropdownButton<String>(
                  value: selectedLanguage,
                  items: [
                    DropdownMenuItem(value: 'en-US', child: Text('English')),
                    DropdownMenuItem(value: 'hi-IN', child: Text('Hindi')),
                    DropdownMenuItem(value: 'mr-IN', child: Text('Marathi')),
                    DropdownMenuItem(value: 'bn-IN', child: Text('Bengali')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      selectedLanguage = val ?? 'en-US';
                    });
                  },
                ),
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Type your question',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _askAI(),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(isListening ? Icons.stop : Icons.mic),
                      label: Text(
                        isListening ? 'Stop Listening' : 'Speech to Text',
                      ),
                      onPressed: isListening ? _stopListening : _startListening,
                    ),
                    SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: Icon(Icons.volume_up),
                      label: Text('Text to Speech'),
                      onPressed: aiResponse.isNotEmpty
                          ? () => _speak(aiResponse)
                          : null,
                    ),
                  ],
                ),
                SizedBox(height: 32),
                if (loading) CircularProgressIndicator(),
                if (aiResponse.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      aiResponse,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                if (searchResults.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Results:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        ...searchResults.map(
                          (r) => Card(
                            child: ListTile(
                              leading: Icon(
                                r['type'] == 'scheme'
                                    ? Icons.account_balance
                                    : r['type'] == 'skill'
                                    ? Icons.school
                                    : r['type'] == 'market'
                                    ? Icons.shopping_basket
                                    : Icons.search,
                                color: Colors.green,
                              ),
                              title: Text(
                                r['name'] ?? r['crop'] ?? r['title'] ?? '',
                              ),
                              subtitle: Text(
                                r['description'] ?? r['market'] ?? '',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
