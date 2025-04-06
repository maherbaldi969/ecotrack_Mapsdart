import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum AlertType { WEATHER, DANGER, SECURITY }
enum SeverityLevel { INFO, WARNING, DANGER }

class WeatherAlert {
  final String id;
  final AlertType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final SeverityLevel severity;
  final List<SafetyAdvice> safetyAdvices;
  final List<AlternativeRoute>? alternatives;

  WeatherAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.severity,
    required this.safetyAdvices,
    this.alternatives,
  });
}

class SafetyAdvice {
  final String title;
  final String description;
  final IconData icon;

  SafetyAdvice({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class AlternativeRoute {
  final String name;
  final String description;
  final LatLng destination;

  AlternativeRoute({
    required this.name,
    required this.description,
    required this.destination,
  });
}

class WeatherData {
  final double temperature;
  final String condition;
  final List<WeatherAlert> alerts;
  final int humidity;
  final double windSpeed;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.alerts,
    required this.humidity,
    required this.windSpeed,
  });
}