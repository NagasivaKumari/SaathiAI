import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'en-US';
  Map<String, String> _localizedStrings = {};

  String get currentLanguage => _currentLanguage;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language_code') ?? 'en-US';
    await _loadLocalizedStrings();
  }

  Future<void> _loadLocalizedStrings() async {
    String langCode = 'en';
    if (_currentLanguage.startsWith('hi')) langCode = 'hi';
    if (_currentLanguage.startsWith('mr')) langCode = 'mr';

    try {
      String jsonString = await rootBundle.loadString(
        'assets/lang/$langCode.json',
      );
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading language file for $langCode: $e');
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    _currentLanguage = languageCode;
    await _loadLocalizedStrings();
  }

  String translate(String key) {
    if (_localizedStrings.isEmpty) {
      return '';
    }
    return _localizedStrings[key] ?? key;
  }
}
