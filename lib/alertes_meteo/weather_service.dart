import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherService {
  final String _apiKey = '67a4b77d36511aa99b34762abd049431';
  final String _baseUrl = 'https://api.weatherapi.com/v1';
  final StreamController<List<Map<String, dynamic>>> _alertController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get weatherAlerts => _alertController.stream;

  Future<void> fetchWeatherAlerts(double lat, double lon) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/alerts.json?key=$_apiKey&q=$lat,$lon'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final alerts = List<Map<String, dynamic>>.from(data['alerts']);
        _alertController.add(alerts);
        await _saveAlertsToCache(alerts);
      }
    } catch (e) {
      debugPrint('Error fetching weather alerts: $e');
    }
  }

  Future<void> _saveAlertsToCache(List<Map<String, dynamic>> alerts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_alerts', json.encode(alerts));
  }

  Future<List<Map<String, dynamic>>> getOfflineAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_alerts');
      if (cachedData != null) {
        return List<Map<String, dynamic>>.from(json.decode(cachedData));
      }
    } catch (e) {
      debugPrint('Erreur de lecture du cache: $e');
    }
    return [];
  }

  void dispose() {
    _alertController.close();
  }
}
