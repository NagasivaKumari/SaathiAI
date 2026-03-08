import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import '../core/config.dart';

class VoiceService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> speak(String text, String langCode) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.BASE_URL}/api/ai/tts'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': '69420',
        },
        body: json.encode({'text': text, 'lang_code': langCode}),
      );

      if (response.statusCode == 200) {
        // Save the bytes to a temporary file
        final bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/sathi_voice.mp3');
        await file.writeAsBytes(bytes);

        // Play the file
        await _audioPlayer.play(DeviceFileSource(file.path));
      } else {
        print('Polly Error: ${response.body}');
      }
    } catch (e) {
      print('VoiceService Error: $e');
    }
  }

  static Future<void> stop() async {
    await _audioPlayer.stop();
  }
}
