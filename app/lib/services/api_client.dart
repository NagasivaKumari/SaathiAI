import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Uri _uri(String path) {
    final normalizedBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
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
}

