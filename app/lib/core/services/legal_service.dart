import 'dart:convert';
import '../../services/api_client.dart';
import 'secure_storage_service.dart';
import '../config.dart';

class LegalService {
  static String get _baseUrl => AppConfig.BASE_URL;
  static ApiClient get _client => ApiClient(baseUrl: _baseUrl);

  static Future<String> _getEmail() async {
    final userStr = await SecureStorageService.getUserProfile();
    if (userStr == null) throw Exception('User not found in storage');
    final map = _parseMap(userStr);
    return map['email'] ?? '';
  }

  static Map<String, dynamic> _parseMap(String str) {
    if (!str.startsWith('{') || !str.endsWith('}')) return {};
    final map = <String, dynamic>{};
    final entries = str.substring(1, str.length - 1).split(', ');
    for (final entry in entries) {
      final idx = entry.indexOf(':');
      if (idx > 0) {
        map[entry.substring(0, idx).trim()] = entry.substring(idx + 1).trim();
      }
    }
    return map;
  }

  static Future<String> fetchTerms() async {
    final response = await _client.fetchTerms();
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data['text'] ?? '';
    }
    throw Exception(data['detail'] ?? 'Failed to load Terms');
  }

  static Future<String> fetchPrivacy() async {
    final response = await _client.fetchPrivacy();
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data['text'] ?? '';
    }
    throw Exception(data['detail'] ?? 'Failed to load Privacy Policy');
  }

  static Future<void> deleteAccount() async {
    final email = await _getEmail();
    final response = await _client.deleteAccount(email);
    final data = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['detail'] ?? 'Failed to delete account');
    }
    await SecureStorageService.clearAll();
  }
}
