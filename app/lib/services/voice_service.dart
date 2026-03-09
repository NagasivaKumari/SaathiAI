import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import '../core/config.dart';

class VoiceService {
    /// Uploads a recorded audio file to the backend for STT (Amazon Transcribe)
    static Future<String?> transcribeAudio(File audioFile, {String langCode = 'en'}) async {
      try {
        final request = http.MultipartRequest('POST', Uri.parse('${AppConfig.BASE_URL}/api/voice/stt'));
        request.files.add(await http.MultipartFile.fromPath('audio', audioFile.path));
        request.fields['lang'] = langCode;
        final streamed = await request.send();
        final response = await http.Response.fromStream(streamed);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data['text'] as String?;
        } else {
          print('STT Error: ${response.body}');
          return null;
        }
      } catch (e) {
        print('VoiceService STT Error: $e');
        return null;
      }
    }
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> speak(String text, String langCode) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('${AppConfig.BASE_URL}/api/voice/tts'));
      request.fields['text'] = text;
      request.fields['lang'] = langCode;
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/sathi_voice.mp3');
        await file.writeAsBytes(bytes);
        await _audioPlayer.play(DeviceFileSource(file.path));
      } else {
        print('TTS Error: ${response.body}');
      }
    } catch (e) {
      print('VoiceService Error: $e');
    }
  }

  static Future<void> stop() async {
    await _audioPlayer.stop();
  }
}
