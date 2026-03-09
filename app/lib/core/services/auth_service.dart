import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage_service.dart';
import '../config.dart';

class AuthService {
  static String get _baseUrl => AppConfig.BASE_URL;

  static Future<Map<String, dynamic>> sendOtp({
    required String email,
    String? username,
    String? phone,
    bool isSignup = false,
  }) async {
    final url = Uri.parse('$_baseUrl/api/auth/send-otp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'username': username,
        'phone': phone,
        'isSignup': isSignup,
      }),
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
    String? name,
    String? username,
    String? phone,
    String? password,
    bool isSignup = false,
  }) async {
    final url = Uri.parse('$_baseUrl/api/auth/verify-otp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'name': name,
        'username': username,
        'phone': phone,
        'password': password,
        'isSignup': isSignup,
      }),
    );
    final data = _processResponse(response);
    if (data['access_token'] != null) {
      await SecureStorageService.saveToken(data['access_token']);
    }
    if (data['refresh_token'] != null) {
      await SecureStorageService.saveRefreshToken(data['refresh_token']);
    }
    if (data['user'] != null) {
      await SecureStorageService.saveUserProfile(data['user']);
    }
    return data;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/api/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = _processResponse(response);
    if (data['access_token'] != null) {
      await SecureStorageService.saveToken(data['access_token']);
    }
    if (data['refresh_token'] != null) {
      await SecureStorageService.saveRefreshToken(data['refresh_token']);
    }
    if (data['user'] != null) {
      await SecureStorageService.saveUserProfile(data['user']);
    }
    return data;
  }

  static Map<String, dynamic> _processResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['detail'] ?? data['message'] ?? 'Unknown error');
    }
  }
}
