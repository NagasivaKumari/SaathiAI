import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  static Future<void> saveUserProfile(Map<String, dynamic> user) async {
    await _storage.write(key: 'user_profile', value: user.toString());
  }

  static Future<String?> getUserProfile() async {
    return await _storage.read(key: 'user_profile');
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
