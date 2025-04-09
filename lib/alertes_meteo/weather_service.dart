import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  final String _apiKey = '67a4b77d36511aa99b34762abd049431';
  final String _baseUrl = 'https://api.weatherapi.com/v1';
  final StreamController<Map<String, dynamic>> _alertController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get weatherAlerts => _alertController.stream;

  Future<void> fetchWeatherAlerts(double lat, double lon) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/alerts.json?key=$_apiKey&q=$lat,$lon'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _alertController.add(data['alerts']);
      }
    } catch (e) {
      debugPrint('Error fetching weather alerts: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getOfflineAlerts() async {
    // Implémentation du cache local pour le mode hors ligne
    return [];
  }

  void dispose() {
    _alertController.close();
  }
}
