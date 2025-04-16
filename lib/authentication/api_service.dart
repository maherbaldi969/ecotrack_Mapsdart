import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'session_manager.dart'; // Importing SessionManager

class ApiService {
  // Configuration
  static const String _baseUrl =
      'http://192.168.112.51/wordpress/wp-json/jwt-auth/v1';
  static const Duration _timeout = Duration(seconds: 15);
  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'EcotrackApp/1.0',
  };

  // Add logs for debugging
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      print('Login request: $username, $password');
      final response = await http
          .post(
            Uri.parse('$_baseUrl/token'),
            headers: _defaultHeaders,
            body: json.encode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(_timeout);

      print('Login response status: ${response.statusCode}');
      print('Login response headers: ${response.headers}');
      print('Login response body: ${response.body}');

      return _processAuthResponse(response);
    } catch (e) {
      print('Login error: $e');
      throw _handleError(e);
    }
  }

  static Future<bool> validateToken(String token) async {
    try {
      print('Validate token request: $token');
      final response = await http.post(
        Uri.parse('$_baseUrl/token/validate'),
        headers: {
          ..._defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      print('Validate token response status: ${response.statusCode}');
      print('Validate token response body: ${response.body}');

      return _processValidateResponse(response);
    } catch (e) {
      print('Validate token error: $e');
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> refreshToken(String token) async {
    try {
      print('Refresh token request: $token');
      final response = await http.post(
        Uri.parse('$_baseUrl/token/refresh'),
        headers: {
          ..._defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      print('Refresh token response status: ${response.statusCode}');
      print('Refresh token response body: ${response.body}');

      final responseData = _processAuthResponse(response);
      if (responseData['success'] == true) {
        // Check if the token exists before accessing it
        if (responseData['token'] != null) {
          // Save the new token if refresh is successful
          await SessionManager.saveToken(responseData['token']);
        } else {
          throw Exception('Token is missing in the response');
        }
      }
      return responseData;
    } catch (e) {
      print('Refresh token error: $e');
      throw _handleError(e);
    }
  }

  // Méthodes de traitement des réponses
  static Map<String, dynamic> _processAuthResponse(http.Response response) {
    final responseData = _parseResponse(response);
    print('Raw API Response: $responseData');

    if (response.statusCode == 200 && responseData['success'] == true) {
      // Extract token from nested data object
      final token = responseData['data']?['token'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing or empty in the response');
      }

      // Extract and parse user data
      final userData = responseData['data'] ?? {};
      print('Extracted User Data: $userData');

      return {
        'success': true,
        'token': token,
        'user': _parseUserData(userData),
      };
    } else {
      throw Exception(responseData['message']?.toString() ??
          responseData['code']?.toString() ??
          'Authentification échouée');
    }
  }

  static bool _processValidateResponse(http.Response response) {
    final responseData = _parseResponse(response);
    return response.statusCode == 200 &&
        (responseData['code'] == 'jwt_auth_valid_token' ||
            responseData['data']['status'] == 200);
  }

  static Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      return json.decode(response.body) as Map<String, dynamic>? ?? {};
    } on FormatException {
      throw Exception('Réponse serveur invalide');
    }
  }

  static Map<String, dynamic> _parseUserData(Map<String, dynamic> data) {
    return {
      'id': data['id'] is int?
          ? data['id']
          : int.tryParse(data['id']?.toString() ?? '0') ?? 0,
      'email': data['email']?.toString() ?? '',
      'username':
          data['nicename']?.toString() ?? data['username']?.toString() ?? '',
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

  // Gestion des erreurs
  static Exception _handleError(dynamic error) {
    if (error is http.ClientException) {
      return Exception('Erreur réseau: ${error.message}');
    } else if (error is TimeoutException) {
      return Exception('Le serveur ne répond pas - temps écoulé');
    } else if (error is FormatException) {
      return Exception('Format de données invalide');
    }
    return Exception(error.toString());
  }
}
