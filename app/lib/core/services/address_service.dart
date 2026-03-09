import 'dart:convert';
import '../../services/api_client.dart';
import 'secure_storage_service.dart';
import '../config.dart';

class AddressService {
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

  static Future<List<dynamic>> getAddresses() async {
    final email = await _getEmail();
    if (email.isEmpty) throw Exception('Email required');
    final response = await _client.getAddresses(email);
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data is List ? data : [];
    }
    throw Exception(data['detail'] ?? 'Failed to load addresses');
  }

  static Future<void> addAddress(Map<String, dynamic> address) async {
    final email = await _getEmail();
    final response = await _client.addAddress(email, address);
    final data = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['detail'] ?? 'Failed to add address');
    }
  }

  static Future<void> updateAddress(
    String id,
    Map<String, dynamic> address,
  ) async {
    final email = await _getEmail();
    final response = await _client.updateAddress(email, id, address);
    final data = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['detail'] ?? 'Failed to update address');
    }
  }

  static Future<void> deleteAddress(String id) async {
    final email = await _getEmail();
    final response = await _client.deleteAddress(email, id);
    final data = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['detail'] ?? 'Failed to delete address');
    }
  }

  static Future<void> setDefaultAddress(String id) async {
    final email = await _getEmail();
    final response = await _client.setDefaultAddress(email, id);
    final data = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['detail'] ?? 'Failed to set default address');
    }
  }
}
