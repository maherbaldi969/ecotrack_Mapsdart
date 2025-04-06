import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'alerts/alert_service.dart';
import 'alerts/weather_service.dart';
import 'widgets/weather_alert_bar.dart';
import 'alerts/alert_models.dart';

class AlertOverlay extends StatefulWidget {
  final Widget child;

  const AlertOverlay({
    super.key,
    required this.child,
  });

  @override
  State<AlertOverlay> createState() => _AlertOverlayState();
}

class _AlertOverlayState extends State<AlertOverlay> {
  bool _showAlert = false;
  WeatherData? _currentWeather;
  late final FlutterLocalNotificationsPlugin _notificationsPlugin;
  Timer? _alertTimer;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      final weatherService = Provider.of<WeatherService>(context, listen: false);
      final alertService = AlertService(_notificationsPlugin);

      await alertService.initialize();
      await _getCurrentLocation();

      if (_currentPosition != null) {
        await weatherService.fetchWeather(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      } else {
        await weatherService.fetchWeather(36.9544, 8.7580);
      }

      weatherService.weatherStream.listen((weather) {
        if (mounted) {
          setState(() {
            _currentWeather = weather;
            _showAlert = weather.alerts.isNotEmpty;
          });

          if (weather.alerts.isNotEmpty) {
            alertService.checkForAlerts(weather);
            _startAlertTimer(); // Démarrer le timer quand une alerte arrive
          }
        }
      });
    } on PlatformException catch (e) {
      print("Erreur de service: ${e.message}");
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  void _startAlertTimer() {
    _alertTimer?.cancel(); // Annuler tout timer existant
    _alertTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && _showAlert) {
        setState(() => _showAlert = false);
      }
    });
  }

  void _dismissAlert() {
    _alertTimer?.cancel();
    setState(() => _showAlert = false);
  }

  @override
  void dispose() {
    _alertTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        if (_showAlert && _currentWeather != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            right: 10,
            child: Dismissible(
              key: ValueKey(_currentWeather!.alerts.first.id),
              direction: DismissDirection.up,
              onDismissed: (_) => _dismissAlert(),
              child: WeatherAlertBar(
                weather: _currentWeather!,
                onTap: _dismissAlert,
              ),
            ),
          ),
      ],
    );
  }
}