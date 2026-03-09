import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'secure_storage_service.dart';

class GamificationService {
  static Future<Map<String, dynamic>?> getUserGamificationData() async {
    try {
      final userStr = await SecureStorageService.getUserProfile();
      if (userStr == null) return null;

      // Parse basic email (ignoring robust json parse for brevity as done elsewhere)
      final emailMatch = RegExp(r"email:\s*([^,}]+)").firstMatch(userStr);
      final email = emailMatch?.group(1)?.trim();
      if (email == null) return null;

      final res = await http.get(
        Uri.parse('${AppConfig.BASE_URL}/api/gamification/$email'),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('Error fetching gamification data: $e');
    }
    return null;
  }

  static Future<bool> awardPoints(String actionType) async {
    try {
      final userStr = await SecureStorageService.getUserProfile();
      if (userStr == null) return false;

      final emailMatch = RegExp(r"email:\s*([^,}]+)").firstMatch(userStr);
      final email = emailMatch?.group(1)?.trim();
      if (email == null) return false;

      final res = await http.post(
        Uri.parse('${AppConfig.BASE_URL}/api/gamification/award'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'action': actionType, // e.g., 'scheme_view', 'skill_complete'
        }),
      );

      return res.statusCode == 200;
    } catch (e) {
      print('Error awarding points: $e');
      return false;
    }
  }
}
