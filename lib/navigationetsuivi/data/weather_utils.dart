import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import '../alerts/alert_service.dart';
import '../alerts/weather_service.dart';
import '../alerts/weather_data.dart';

class WeatherUtils {
  static Future<Map<String, dynamic>?> fetchWeatherInfo(
      double latitude, double longitude) async {
    const apiKey = '67a4b77d36511aa99b34762abd049431';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric&lang=fr';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'weather': data['weather'][0]['description'],
          'temperature': data['main']['temp'],
          'humidity': data['main']['humidity'],
        };
      }
      return null;
    } catch (e) {
      print("Erreur lors de la récupération des informations météo: $e");
      return null;
    }
  }

  static Widget buildWeatherDetailRow(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  static Future<StreamSubscription<dynamic>?> initializeWeatherMonitoring(
      WeatherService weatherService,
      AlertService alertService,
      Position? currentPosition) async {
    await alertService.initialize();

    final weatherSubscription = weatherService.weatherStream.listen((weather) {
      alertService.checkForAlerts(weather);
    });

    if (currentPosition != null) {
      weatherService.fetchWeather(
        currentPosition.latitude,
        currentPosition.longitude,
      );
    }

    return weatherSubscription;
  }
}
