import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LanguageService with ChangeNotifier {
  static const String _translateApiKey = 'YOUR_API_KEY'; // Remplacez par votre clé
  static const String _translateUrl = 'https://translation.googleapis.com/language/translate/v2';

  static const String _prefKey = 'selected_language';
  String _currentLanguage = 'fr';
  final Map<String, String> _availableLanguages = {
    'fr': 'Français',
    'en': 'English',
    'es': 'Español'
  };

  LanguageService() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_prefKey) ?? 'fr';
    notifyListeners();
  }

  String get currentLanguage => _currentLanguage;
  Map<String, String> get availableLanguages => _availableLanguages;

  Future<void> changeLanguage(String languageCode) async {
    if (!_availableLanguages.containsKey(languageCode)) return;
    
    _currentLanguage = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, languageCode);
    notifyListeners();
  }

  Future<String> translateText(String text, String targetLang) async {
    try {
      final response = await http.post(
        Uri.parse(_translateUrl),
        body: {
          'q': text,
          'target': targetLang,
          'key': _translateApiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['translations'][0]['translatedText'];
      }
      return text; // Retourne le texte original en cas d'erreur
    } catch (e) {
      return text;
    }
  }
}
