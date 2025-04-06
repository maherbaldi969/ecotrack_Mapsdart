import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(MaterialApp(
    home: LocationAlertsPage(),
  ));
}

class LocationAlertsPage extends StatefulWidget {
  @override
  _LocationAlertsPageState createState() => _LocationAlertsPageState();
}

class _LocationAlertsPageState extends State<LocationAlertsPage> {
  final LocationAlerts locationAlerts = LocationAlerts();
  LatLng? destination;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await locationAlerts.initNotifications();

    // Définir une destination de test (exemple : Paris)
    setState(() {
      destination = LatLng(48.8566, 2.3522);
    });

    // Démarrer le suivi de la position
    if (destination != null) {
      locationAlerts.trackLocation(destination!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alertes de Localisation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Test des alertes de localisation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            if (destination != null)
              Text(
                'Destination : ${destination!.latitude}, ${destination!.longitude}',
                style: TextStyle(fontSize: 16),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Redémarrer le suivi de la position
                if (destination != null) {
                  locationAlerts.trackLocation(destination!);

                  // Afficher un SnackBar pour confirmer le redémarrage
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Suivi de la position redémarré.'),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Simuler une déviation de position
                  _simulateDeviation(context);
                }
              },
              child: Text('Redémarrer le suivi'),
            ),
          ],
        ),
      ),
    );
  }

  // Simuler une déviation de position
  void _simulateDeviation(BuildContext context) {
    final simulatedPosition = LatLng(48.8600, 2.3600); // Position simulée éloignée
    final distance = locationAlerts._calculateDistance(simulatedPosition, destination!);

    if (distance > 100) {
      // Afficher un Dialog pour indiquer une déviation
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Déviation détectée'),
            content: Text('Vous vous êtes écarté de l\'itinéraire prévu.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}

class LocationAlerts {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialisation des notifications
  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Afficher une notification
  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'location_alerts_channel',
      'Location Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // Suivi de la position en temps réel
  void trackLocation(LatLng destination) {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Mettre à jour la position tous les 10 mètres
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      final currentLocation = LatLng(position.latitude, position.longitude);

      // Calculer la distance entre la position actuelle et la destination
      final distance = _calculateDistance(currentLocation, destination);

      // Vérifier si l'utilisateur s'écarte de l'itinéraire
      if (distance > 100) {
        // 100 mètres de déviation
        showNotification(
          'Déviation de l\'itinéraire',
          'Vous vous êtes écarté de l\'itinéraire prévu.',
        );
      }

      // Vérifier si l'utilisateur est immobile pendant une période prolongée
      if (position.speed < 1) {
        // Vitesse inférieure à 1 m/s
        showNotification(
          'Difficulté détectée',
          'Vous semblez être immobile depuis un moment.',
        );
      }
    });
  }

  // Calculer la distance entre deux points (en mètres)
  double _calculateDistance(LatLng point1, LatLng point2) {
    final Distance distance = Distance();
    return distance(point1, point2);
  }
}