import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const _keyActivity = 'pref_activity';
  static const _keyDuration = 'pref_duration'; 
  static const _keyBudget = 'pref_budget';
  static const _keyLanguage = 'pref_language';

  Future<Map<String, dynamic>> getUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'activityType': prefs.getString(_keyActivity) ?? '',
      'duration': prefs.getString(_keyDuration) ?? '',
      'budget': prefs.getString(_keyBudget) ?? '',
      'language': prefs.getString(_keyLanguage) ?? '',
    };
  }

  Future<void> saveUserPreferences({
    required String activityType,
    required String duration,
    required String budget,
    required String language,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_keyActivity, activityType),
      prefs.setString(_keyDuration, duration),
      prefs.setString(_keyBudget, budget),
      prefs.setString(_keyLanguage, language),
    ]);
  }
}
