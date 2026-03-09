import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage_service.dart';
import '../config.dart';

class ProfileService {
  static String get _baseUrl => AppConfig.BASE_URL;

  static Future<Map<String, dynamic>> fetchProfile() async {
    final token = await SecureStorageService.getToken();
    if (token == null) throw Exception('Not authenticated');
    final url = Uri.parse('$_baseUrl/api/user/profile');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      await SecureStorageService.saveUserProfile(data);
      return data;
    } else {
      throw Exception(data['detail'] ?? data['message'] ?? 'Unknown error');
    }
  }
}
