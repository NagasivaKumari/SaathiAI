import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _client;
  final _storage = const FlutterSecureStorage();

  ApiClient({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  Uri _uri(String path) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  Future<String?> getToken() async => await _storage.read(key: 'jwt_token');
  Future<void> setToken(String token) async =>
      await _storage.write(key: 'jwt_token', value: token);
  Future<void> clearToken() async => await _storage.delete(key: 'jwt_token');

  Future<http.Response> _post(
    String path,
    Map<String, dynamic> data, {
    bool auth = false,
  }) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return await _client.post(
      _uri(path),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  Future<http.Response> _get(
    String path, {
    bool auth = false,
    Map<String, String>? params,
  }) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    final uri = _uri(path).replace(queryParameters: params);
    return await _client.get(uri, headers: headers);
  }

  // Auth
  Future<http.Response> signup(
    String email,
    String password, {
    String? phone,
  }) async => _post('/auth/signup', {
    'email': email,
    'password': password,
    'phone': phone,
  });
  Future<http.Response> login(
    String email,
    String password, {
    String? otp,
  }) async =>
      _post('/auth/login', {'email': email, 'password': password, 'otp': otp});
  Future<http.Response> sendOtp(String email) async =>
      _post('/auth/send-otp', {'email': email});
  Future<http.Response> verifyOtp(String email, String otp) async =>
      _post('/auth/verify-otp', {'email': email, 'otp': otp});
  Future<http.Response> forgotPassword(String email) async =>
      _post('/auth/forgot-password', {'email': email});
  Future<http.Response> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async => _post('/auth/reset-password', {
    'email': email,
    'otp': otp,
    'new_password': newPassword,
  });
  Future<http.Response> logoutAll() async =>
      _post('/auth/logout-all', {}, auth: true);

  // Profile
  Future<http.Response> getProfile(String email) async =>
      _get('/profile', auth: true, params: {'email': email});
  Future<http.Response> updateProfile(Map<String, dynamic> profile) async =>
      _post('/profile', profile, auth: true);
  Future<http.Response> changePassword(
    String email,
    String oldPassword,
    String newPassword,
  ) async => _post('/profile/change-password', {
    'email': email,
    'old_password': oldPassword,
    'new_password': newPassword,
  }, auth: true);

  // Address
  Future<http.Response> getAddresses(String email) async =>
      _get('/addresses', auth: true, params: {'email': email});
  Future<http.Response> addAddress(
    String email,
    Map<String, dynamic> address,
  ) async => _post('/addresses', {'email': email, ...address}, auth: true);
  Future<http.Response> updateAddress(
    String email,
    String addressId,
    Map<String, dynamic> address,
  ) async =>
      _post('/addresses/$addressId', {'email': email, ...address}, auth: true);
  Future<http.Response> deleteAddress(String email, String addressId) async =>
      _post('/addresses/$addressId/delete', {'email': email}, auth: true);
  Future<http.Response> setDefaultAddress(
    String email,
    String addressId,
  ) async =>
      _post('/addresses/default/$addressId', {'email': email}, auth: true);

  // Settings
  Future<http.Response> getSettings(String email) async =>
      _get('/settings', auth: true, params: {'email': email});
  Future<http.Response> updateSettings(
    String email,
    Map<String, dynamic> settings,
  ) async => _post('/settings', {'email': email, ...settings}, auth: true);

  // Support
  Future<http.Response> contactSupport(Map<String, dynamic> payload) async =>
      _post('/support/contact', payload, auth: true);
  Future<http.Response> fetchFaq() async => _get('/support/faq', auth: true);
  Future<http.Response> reportProblem(Map<String, dynamic> payload) async =>
      _post('/support/report', payload, auth: true);

  // Legal
  Future<http.Response> fetchTerms() async => _get('/legal/terms');
  Future<http.Response> fetchPrivacy() async => _get('/legal/privacy');
  Future<http.Response> deleteAccount(String email) async =>
      _post('/legal/delete-account', {'email': email}, auth: true);

  // Notifications
  Future<List<dynamic>> getNotifications() async {
    try {
      final res = await _get('/api/notifications', auth: true);
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      // Ignore error and return empty list
    }
    return [];
  }

  Future<List<dynamic>> globalSearch(
    String query, {
    String? type,
    String? state,
    String? district,
    String lang = 'en-US',
  }) async {
    final params = <String, String>{'q': query, 'lang': lang};
    if (type != null) params['type'] = type;
    if (state != null) params['state'] = state;
    if (district != null) params['district'] = district;
    final uri = Uri.parse(
      '$baseUrl/api/search',
    ).replace(queryParameters: params);
    final res = await _client.get(uri);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Global search failed: ${res.statusCode}');
    }
  }

  Future<Map<String, dynamic>> health() async {
    final res = await _client.get(_uri('/api/health'));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Health failed (${res.statusCode}): ${res.body}');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception('Unexpected health response: ${res.body}');
  }

  Future<List<dynamic>> marketPrices() async {
    final res = await _client.get(_uri('/api/market/prices'));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Market prices failed (${res.statusCode}): ${res.body}');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is List) return decoded;
    throw Exception('Unexpected market response: ${res.body}');
  }

  Future<List<dynamic>> getSchemes({String lang = 'en'}) async {
    final res = await _client.get(_uri('/api/schemes?lang=$lang'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load schemes');
    }
  }

  Future<List<dynamic>> getSkills({String lang = 'en'}) async {
    final res = await _client.get(_uri('/api/skills?lang=$lang'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load skills');
    }
  }

  Future<List<dynamic>> getSchemesBulk({String lang = 'en'}) async {
    final res = await _client.get(_uri('/api/schemes/bulk?lang=$lang'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load bulk schemes');
    }
  }

  Future<List<dynamic>> getSkillsBulk({String lang = 'en'}) async {
    final res = await _client.get(_uri('/api/skills/bulk?lang=$lang'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load bulk skills');
    }
  }

  Future<List<dynamic>> getMarketBulk({String lang = 'en'}) async {
    final res = await _client.get(_uri('/api/market/bulk?lang=$lang'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load bulk market data');
    }
  }

  Future<Map<String, dynamic>> getSchemeDetail(String id) async {
    final res = await _client.get(_uri('/api/schemes/$id'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load scheme details');
    }
  }
}
