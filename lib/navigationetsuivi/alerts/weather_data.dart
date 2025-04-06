import 'package:flutter/material.dart';

class WeatherData {
  final String condition;
  final double temperature;
  final int humidity;
  final List<WeatherAlert> alerts;

  WeatherData({
    required this.condition,
    required this.temperature,
    required this.humidity,
    this.alerts = const [],
  });
}

class WeatherAlert {
  final String title;
  final String description;
  final Color color;

  WeatherAlert({
    required this.title,
    required this.description,
    this.color = Colors.orange,
  });
}
