import 'dart:io';
import 'package:record/record.dart';

class AudioRecorderService {
  static final AudioRecorder _recorder = AudioRecorder();

  static Future<void> startRecording(String filePath) async {
    if (await _recorder.hasPermission()) {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 16000,
        ),
        path: filePath,
      );
    }
  }

  static Future<File?> stopRecording() async {
    final path = await _recorder.stop();
    if (path != null) {
      return File(path);
    }
    return null;
  }

  static Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }
}
