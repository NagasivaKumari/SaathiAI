import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  static const Duration _timeout = Duration(seconds: 10);

  final String baseUrl;
  final http.Client _client;

  Uri _uri(String path) {
    final normalizedBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  Future<http.Response> _get(Uri uri) async {
    return _client.get(uri).timeout(_timeout);
  }

  Future<List<dynamic>> globalSearch(String query, {String? type, String? state, String? district, String lang = 'en-US'}) async {
    final params = <String, String>{'q': query, 'lang': lang};
    if (type != null) params['type'] = type;
    if (state != null) params['state'] = state;
    if (district != null) params['district'] = district;
    final uri = Uri.parse(baseUrl + '/api/search').replace(queryParameters: params);
    final res = await _get(uri);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Global search failed: ${res.statusCode}');
    }
  }

  Future<Map<String, dynamic>> health() async {
    final res = await _get(_uri('/api/health'));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Health failed (${res.statusCode}): ${res.body}');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception('Unexpected health response: ${res.body}');
  }

  Future<List<dynamic>> marketPrices() async {
    final res = await _get(_uri('/api/market/prices'));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Market prices failed (${res.statusCode}): ${res.body}');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is List) return decoded;
    throw Exception('Unexpected market response: ${res.body}');
  }

  Future<List<dynamic>> getSchemes() async {
    final res = await _get(_uri('/api/schemes'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load schemes');
    }
  }

  Future<List<dynamic>> getSkills() async {
    final res = await _get(_uri('/api/skills'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load skills');
    }
  }

  Future<Map<String, dynamic>> getSchemeDetail(String id) async {
    final res = await _get(_uri('/api/schemes/$id'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load scheme details');
    }
  }
}

