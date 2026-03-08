import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/api_client.dart';
import 'package:voice_search/voice_search.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  final ApiClient api = ApiClient(baseUrl: 'http://10.0.2.2:8000');
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
    setState(() { loading = true; aiResponse = ''; searchResults = []; searching = true; });
    try {
      final results = await api.globalSearch(query, lang: selectedLanguage);
      setState(() { searchResults = results; });
      if (results.isEmpty) {
        setState(() { aiResponse = 'No results found.'; });
      } else {
        setState(() { aiResponse = ''; });
      }
    } catch (e) {
      setState(() { aiResponse = 'Network error'; });
    }
    setState(() { loading = false; searching = false; });
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
      speech.listen(
        onResult: (result) {
          setState(() {
            transcript = result.recognizedWords;
            _controller.text = transcript;
          });
        },
        localeId: selectedLanguage,
      );
    }
  }

  void _stopListening() {
    speech.stop();
    setState(() => isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Ask Saathi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                  // Add more languages as needed
                ],
                onChanged: (val) {
                  setState(() { selectedLanguage = val ?? 'en-US'; });
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
                    label: Text(isListening ? 'Stop Listening' : 'Speech to Text'),
                    onPressed: isListening ? _stopListening : _startListening,
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.volume_up),
                    label: Text('Text to Speech'),
                    onPressed: aiResponse.isNotEmpty ? () => _speak(aiResponse) : null,
                  ),
                ],
              ),
              SizedBox(height: 32),
              if (loading) CircularProgressIndicator(),
              if (aiResponse.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(aiResponse, style: TextStyle(color: Colors.black, fontSize: 16)),
                ),
              if (searchResults.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Results:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
