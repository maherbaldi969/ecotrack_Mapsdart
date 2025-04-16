import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'dart:convert';

class SessionManager {
  // Clés de stockage
  static const String _tokenKey = 'jwt_token';
  static const String _userDataKey = 'user_data';
  static const String _lastLoginKey = 'last_login';

  /// Sauvegarde le token JWT
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await _updateLastLogin();
      debugPrint('JWT token saved successfully');
    } catch (e) {
      debugPrint('Error saving token: $e');
      rethrow;
    }
  }

  /// Sauvegarde les données utilisateur
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (userData.isNotEmpty) {
        final sanitizedData = _sanitizeUserData(userData);
        await prefs.setString(_userDataKey, json.encode(sanitizedData));
        debugPrint('User data saved: $sanitizedData');
      } else {
        debugPrint('No user data to save');
      }
    } catch (e) {
      debugPrint('Error saving user data: $e');
      rethrow;
    }
  }

  /// Récupère les données utilisateur
  static Future<Map<String, dynamic>> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_userDataKey);
      
      if (data == null || data.isEmpty) {
        debugPrint('No user data found');
        return {};
      }
      
      final userData = json.decode(data) as Map<String, dynamic>;
      debugPrint('Retrieved user data: $userData');
      return userData;
    } catch (e) {
      debugPrint('Error retrieving user data: $e');
      return {};
    }
  }

  /// Vérifie si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenExists = prefs.getString(_tokenKey) != null;
      debugPrint('User login status: $tokenExists');
      return tokenExists;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  /// Déconnecte l'utilisateur
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_tokenKey),
        prefs.remove(_userDataKey),
        prefs.remove(_lastLoginKey),
      ]);
      debugPrint('User logged out successfully');
    } catch (e) {
      debugPrint('Error during logout: $e');
      rethrow;
    }
  }

  /// Récupère le token JWT
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('Error retrieving token: $e');
      return null;
    }
  }

  // Méthodes privées
  static Future<void> _updateLastLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
  }

  static Map<String, dynamic> _sanitizeUserData(Map<String, dynamic> data) {
    return {
      'id': data['id'] is int? ? data['id'] : int.tryParse(data['id']?.toString() ?? '0') ?? 0,
      'email': data['email']?.toString() ?? '',
      'username': data['username']?.toString() ?? '',
      'displayName': data['displayName']?.toString() ?? 'Utilisateur',
      'firstName': data['firstName']?.toString() ?? '',
      'lastName': data['lastName']?.toString() ?? '',
      'roles': _parseRoles(data['roles']),
    };
  }

  static List<String> _parseRoles(dynamic roles) {
    if (roles is List) {
      return roles.map((e) => e.toString()).toList();
    }
    return [];
  }
}
