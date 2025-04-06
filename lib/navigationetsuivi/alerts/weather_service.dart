import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'alert_models.dart';
import 'safety_database.dart';

class WeatherService {
  final String _apiKey = '67a4b77d36511aa99b34762abd049431';
  final StreamController<WeatherData> _weatherStreamController =
  StreamController<WeatherData>.broadcast();

  Stream<WeatherData> get weatherStream => _weatherStreamController.stream;
  Position? _currentPosition;

  Future<void> fetchWeather([double? lat, double? lng]) async {
    try {
      // Essayer d'obtenir la position actuelle si non fournie
      if (lat == null || lng == null) {
        await _getCurrentPosition();
        lat = _currentPosition?.latitude ?? 36.9544; // Tabarka par défaut
        lng = _currentPosition?.longitude ?? 8.7580;
      }

      final url = Uri.parse(
          'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lng'
              '&exclude=minutely,hourly&appid=$_apiKey&units=metric&lang=fr'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _weatherStreamController.add(_parseWeatherData(data));
      } else {
        _emitDefaultData(lat, lng);
      }
    } catch (e) {
      print('Erreur météo: $e');
      _emitDefaultData(lat ?? 36.9544, lng ?? 8.7580);
    }
  }

  Future<void> _getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );
    } catch (e) {
      print('Erreur géolocalisation: $e');
    }
  }

  WeatherData _parseWeatherData(Map<String, dynamic> data) {
    final current = data['current'];
    final weather = current['weather'][0];

    return WeatherData(
      temperature: current['temp']?.toDouble() ?? 0,
      condition: _translateWeatherCondition(weather['description']),
      alerts: _parseAlerts(data['alerts']),
      humidity: current['humidity']?.toInt() ?? 0,
      windSpeed: current['wind_speed']?.toDouble() ?? 0,
    );
  }

  List<WeatherAlert> _parseAlerts(List<dynamic>? alerts) {
    return alerts?.map((alert) => WeatherAlert(
      id: alert['id'].toString(),
      type: AlertType.WEATHER,
      title: _translateAlertTitle(alert['event']),
      description: alert['description'] ?? 'Alerte météorologique',
      timestamp: DateTime.fromMillisecondsSinceEpoch(alert['start'] * 1000),
      severity: _parseSeverity(alert['severity'] ?? 'warning'),
      safetyAdvices: _getRelevantSafetyAdvices(alert['event']),
    )).toList() ?? [];
  }

  String _translateWeatherCondition(String condition) {
    const conditionsMap = {
      'clear': 'Ciel dégagé',
      'clouds': 'Nuageux',
      'rain': 'Pluie',
      'thunderstorm': 'Orage',
      'snow': 'Neige',
      'mist': 'Brume',
      'fog': 'Brouillard'
    };
    return conditionsMap[condition.toLowerCase()] ?? condition;
  }

  String _translateAlertTitle(String title) {
    const titlesMap = {
      'storm': 'Alerte Tempête',
      'heat': 'Alerte Canicule',
      'flood': 'Alerte Inondation',
      'wind': 'Alerte Vent Violent',
      'fire': 'Alerte Feu de Forêt'
    };

    final lowerTitle = title.toLowerCase();
    return titlesMap.entries
        .firstWhere((e) => lowerTitle.contains(e.key),
        orElse: () => MapEntry('', title))
        .value;
  }

  List<SafetyAdvice> _getRelevantSafetyAdvices(String event) {
    final lowerEvent = event.toLowerCase();

    if (lowerEvent.contains('storm') || lowerEvent.contains('thunderstorm')) {
      return SafetyDatabase.getAdvicesForCondition('orage');
    } else if (lowerEvent.contains('heat')) {
      return SafetyDatabase.getAdvicesForCondition('chaleur');
    } else if (lowerEvent.contains('flood')) {
      return SafetyDatabase.getAdvicesForCondition('inondation');
    } else if (lowerEvent.contains('wind')) {
      return SafetyDatabase.getAdvicesForCondition('vent');
    } else {
      return SafetyDatabase.getDefaultAdvices();
    }
  }

  SeverityLevel _parseSeverity(String severity) {
    switch (severity.toLowerCase()) {
      case 'danger': return SeverityLevel.DANGER;
      case 'warning': return SeverityLevel.WARNING;
      default: return SeverityLevel.INFO;
    }
  }

  void _emitDefaultData(double lat, double lng) {
    _weatherStreamController.add(WeatherData(
      temperature: _estimateTemperature(lat),
      condition: _estimateWeatherCondition(lat, lng),
      alerts: [],
      humidity: _estimateHumidity(lat),
      windSpeed: _estimateWindSpeed(lat),
    ));
  }

  // Méthodes d'estimation pour les données par défaut
  double _estimateTemperature(double lat) {
    // Logique simplifiée pour le nord (plus froid) vs sud de la Tunisie
    return lat > 35 ? 28.0 : 32.0;
  }

  String _estimateWeatherCondition(double lat, double lng) {
    // Nord-ouest (Tabarka) plus pluvieux
    return lat > 36 && lng < 9 ? 'Nuageux' : 'Dégagé';
  }

  int _estimateHumidity(double lat) {
    return lat > 36 ? 65 : 50;
  }

  double _estimateWindSpeed(double lat) {
    return lat > 36 ? 15.0 : 10.0;
  }

  void dispose() {
    _weatherStreamController.close();
  }
}