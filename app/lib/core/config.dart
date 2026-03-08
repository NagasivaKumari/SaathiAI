import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Backend base URL. Works without .env (uses fallback).
/// Set BASE_URL in app/.env for production, or use default for Android emulator.
class AppConfig {
  static const String _fallbackBaseUrl = 'http://10.0.2.2:8000';

  static String get BASE_URL {
    try {
      final v = dotenv.env['BASE_URL'];
      if (v != null && v.trim().isNotEmpty) return v.trim();
    } catch (_) {
      // dotenv not loaded (NotInitializedError) or .env missing
    }
    return _fallbackBaseUrl;
  }
}
