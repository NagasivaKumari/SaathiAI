import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get BASE_URL =>
      dotenv.env['BASE_URL'] ?? 'http://192.168.29.254:8000';
}
