import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; // Importation du package http
import 'dart:convert'; // Pour utiliser json.decode
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'DangerPage.dart';
import 'dart:async'; // Ajoutez cette ligne
import '../chat/chat_list_screen.dart';
import '../chat/chat_screen.dart';
import 'alerts/alert_models.dart';
import 'alerts/alert_service.dart';
import 'alerts/weather_service.dart';
import 'alerts/safety_database.dart';
import 'widgets/weather_alert_bar.dart';
import 'widgets/safety_tips_card.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'data/markers_utils.dart';
import 'data/custom_menu.dart';
import 'data/filtre_utils.dart';

class MapsPage extends StatefulWidget {
  @override
  _MapsPageState createState() => _MapsPageState();
  final LatLng? initialPosition; // Ajoutez ce paramètre

  // Ajoutez un constructeur pour accepter initialPosition
  MapsPage({this.initialPosition});
}

class _MapsPageState extends State<MapsPage> {
  //  Déclaration des variables pour la carte, les marqueurs et les itinéraires
  GoogleMapController? mapController;
  final LatLng _center = const LatLng(36.9541, 8.7586);
  final LatLng _bizerteItineraryLocation = const LatLng(37.2744, 9.8739);
  final LatLng _center_kesra = const LatLng(35.8136, 9.3644);
  final LatLng _center_1001NightsPalace =
      const LatLng(36.5044, 8.7756); // Coordonnées de 1001-Nights Palace
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {}; //trajet
  TextEditingController _searchController = TextEditingController();
  LatLng? _destination; // Destination sélectionnée par l'utilisateur
  double? _distanceRemaining; // Distance restante en kilomètres
  Position? _currentPosition; // Position actuelle de l'utilisateur
  bool _alertShown = false;
  final LatLng _defaultCenter =
      const LatLng(36.9541, 8.7586); // Centre par défaut
  LatLng? _initialCameraPosition; // Position initiale de la caméra
  late final WeatherService _weatherService;
  late final AlertService _alertService;
  WeatherData? _currentWeather;
  StreamSubscription<WeatherData>? _weatherSubscription;
  bool _isOnline = true;
  Position? _lastPosition;
  StreamSubscription<Position>? _positionStream;
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    // Utilisez initialPosition si fourni, sinon utilisez le centre par défaut
    _initialCameraPosition = widget.initialPosition ?? _defaultCenter;
    _addItineraryMarker();
    // Utilisation des fonctions du fichier markers_utils.dart
    loadMarkersHebergements(_markers, context, _showRandoDialogWrapper);
    loadMarkersGuides(_markers, context, _showGuideDialogWrapper);
    loadMarkersRandonnees(_markers, context, _showRandoDialogWrapper);
    _center_1001NightsPalace;
    _getCurrentLocation();
    _initializeNotifications(); // Initialiser les notifications
    _weatherService = WeatherService();
    _alertService = AlertService(flutterLocalNotificationsPlugin);
    _initializeWeatherMonitoring();
    _checkConnectivity(); // Utilisation des nouvelles fonctions
    // Vérifier la distance toutes les 30 secondes
    Timer.periodic(Duration(seconds: 15), (Timer timer) {
      _checkDistanceToKesra(); // Appeler la fonction pour vérifier la distance à Kesra
    });
  }

// Wrapper pour les dialogues de randonnée
  void _showRandoDialogWrapper(Map<String, dynamic> rando) {
    showRandonneesDialog(
        rando, context, (nom) => _afficherDetailsRandonneeWrapper(nom));
  }

// Wrapper pour les dialogues de guide
  void _showGuideDialogWrapper(Map<String, dynamic> guide) {
    showGuideDialog(guide, context, (nom) => _contacterGuideWrapper(nom));
  }

// Wrapper pour les détails de randonnée
  Future<void> _afficherDetailsRandonneeWrapper(String nom) async {
    try {
      await afficherDetailsRandonnee(nom);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: ${e.toString()}")),
      );
    }
  }

// Wrapper pour contacter guide
  void _contacterGuideWrapper(String guide) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Contact en cours avec $guide")),
    );
  }

  Future<void> _initializeWeatherMonitoring() async {
    await _alertService.initialize();

    _weatherSubscription = _weatherService.weatherStream.listen((weather) {
      if (mounted) {
        setState(() => _currentWeather = weather);
      }
      _alertService.checkForAlerts(weather);
    });

    // Vérification initiale
    if (_currentPosition != null) {
      _weatherService.fetchWeather(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    }
  }

  Future<void> _checkConnectivity() async {
    final connectivity = Connectivity();
    _isOnline =
        await connectivity.checkConnectivity() != ConnectivityResult.none;

    connectivity.onConnectivityChanged.listen((result) {
      if (mounted) {
        setState(() => _isOnline = result != ConnectivityResult.none);
      }
      if (_isOnline) {
        _alertService.syncPendingAlerts();
      }
    });
  }

  @override
  void dispose() {
    _weatherSubscription?.cancel();
    _weatherService.dispose();
    super.dispose();
  }

  void _showWeatherDetails() {
    if (_currentWeather == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails météorologiques',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildWeatherDetailRow(Icons.thermostat, 'Température',
                '${_currentWeather!.temperature.toStringAsFixed(1)}°C'),
            _buildWeatherDetailRow(
                Icons.water_drop, 'Humidité', '${_currentWeather!.humidity}%'),
            _buildWeatherDetailRow(Icons.air, 'Vent',
                '${_currentWeather!.windSpeed.toStringAsFixed(1)} km/h'),
            const SizedBox(height: 16),
            if (_currentWeather!.alerts.isNotEmpty) ...[
              Text(
                'Alertes actives',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ..._currentWeather!.alerts
                  .map((alert) => ListTile(
                        leading:
                            const Icon(Icons.warning, color: Colors.orange),
                        title: Text(alert.title),
                        subtitle: Text(alert.description),
                      ))
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetailRow(IconData icon, String label, String value) {
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

  void _checkDistanceToKesra() {
    if (!mounted || _currentPosition == null)
      return; // Vérifier si le widget est monté
    if (_currentPosition == null) {
      print("🚨 _currentPosition est null !");
      return;
    }

    print("Vérification de la distance...");

    final distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          _center_kesra.latitude,
          _center_kesra.longitude,
        ) /
        1000; // Convertir en kilomètres

    print("Distance calculée : $distance km");

    if (distance >= 5 && distance <= 20) {
      if (!_alertShown) {
        // Vérifier si l'alerte a déjà été affichée
        print("✅ Distance valide, affichage de l'alerte...");
        _alertShown = true; // Marquer l'alerte comme affichée
        _showAlert(
          "Vous êtes proche de Kesra \n Découvrez Kesra : un trésor caché de la Tunisie ",
          "Il reste ${distance.toStringAsFixed(2)} km pour atteindre Kesra.",
          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
          textAlign: TextAlign.center,
        );
      } else {
        print("⚠️ Alerte déjà affichée, pas de nouvelle alerte.");
      }
    } else {
      print(
          "❌ Distance hors de l'intervalle (5-20 km), réinitialisation de l'alerte.");
      _alertShown =
          false; // Réinitialiser lorsque l'utilisateur sort de la zone
    }
  }

  void _showAlert(String title, String message,
      {TextStyle? style, TextAlign? textAlign}) {
    if (!mounted) return; // Vérifier si le widget est monté
    print("🟢 Tentative d'affichage de l'alerte...");

    // Temporarily remove the _alertShown flag for testing
    // if (_alertShown) return;

    showDialog(
      context: context,
      barrierDismissible: false, // Empêche la fermeture en appuyant à côté
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // _alertShown = false; // Réinitialisation après fermeture manuelle
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    ).then((_) {
      print("🔴 Alerte fermée");
      // _alertShown = false; // Réinitialisation après fermeture
    });

    // Fermer automatiquement après 30 secondes
    Future.delayed(Duration(seconds: 30), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
        print("🔴 Alerte fermée automatiquement après 30 secondes");
        // _alertShown = false; // Réinitialisation après fermeture automatique
      }
    });
  }

  //  Ajoute un marqueur pour l'itinéraire de randonnée Cap Blanc à Bizerte
  void _addItineraryMarker() {
    if (!mounted) return; // Vérifier si le widget est monté
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId("itinerary_bizerte"),
          position: _bizerteItineraryLocation,
          infoWindow: const InfoWindow(
            title: "Randonnée Cap Blanc",
            snippet: "Un itinéraire magnifique au nord de Bizerte",
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          onTap: () {
            _showItineraryDetails(context);
          },
        ),
      );
    });
  }

//  Affiche une boîte de dialogue avec les détails d'une randonnée
  void _showDetailsDialog(BuildContext context) {
    if (!mounted) return; // Vérifier si le widget est monté
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/intinaire.jpeg', width: 300),
              const SizedBox(height: 10),
              const Text(
                "Randonnée à Jebel Serj",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 5),
              const Text("Distance: 12 km | Durée: 5h | Altitude: 1357 m"),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/itineraries');
                },
                child: const Text("Voir détails"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Fermer"),
            ),
          ],
        );
      },
    );
  }

// Affiche une boîte de dialogue avec les détails de l'itinéraire de randonnée
  void _showItineraryDetails(BuildContext context) {
    Map<String, dynamic> itinerary = {
      "title": "Randonnée Cap Blanc",
      "image_url": "https://example.com/images/cap_blanc.jpg",
      "distance": 10.5,
      "duration": "2h 30min",
      "altitude": 250,
      "description":
          "Un superbe itinéraire longeant le littoral de Bizerte, offrant des vues panoramiques sur la mer.",
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(itinerary["title"]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/capbizerte.jpeg', width: 300),
              const SizedBox(height: 8),
              Text(itinerary["description"]),
              const SizedBox(height: 8),
              const Text("⭐ 4.8/5 - 120 avis"),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/itineraries');
                },
                child: const Text("Voir détails"),
              ),
              ElevatedButton(
                onPressed: () {
                  // Fonction pour enregistrer l'itinéraire
                },
                child: const Text("Enregistrer l’itinéraire"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fermer"),
            ),
          ],
        );
      },
    );
  }

// Fonction pour partager la position avec un guide
  void _sharePositionWithGuide() async {
    if (_currentPosition == null) {
      _showSnackBar("Impossible de récupérer la position actuelle.");
      return;
    }

    // Naviguer vers ChatListScreen pour sélectionner un guide
    final selectedGuide = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatListScreen(isSelectingGuide: true),
      ),
    );

    if (selectedGuide != null) {
      // Envoyer la position au guide sélectionné
      _sendPositionToGuide(selectedGuide, _currentPosition!);

      // Ouvrir la discussion avec le guide après l'envoi de la position
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            user: selectedGuide['name'],
            messages: [
              {
                'message':
                    'Position partagée: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
                'sender': 'Vous',
                'latitude': _currentPosition!.latitude,
                'longitude': _currentPosition!.longitude,
              }
            ], // Passer la liste des messages avec la position
            onSendMessage: (message, sender) {
              // Gérer l'envoi du message ici
              print("Message envoyé : $message par $sender");
            },
            onLocationMessageTap: (latitude, longitude) {
              _navigateToMapWithCoordinates(latitude, longitude);
            },
          ),
        ),
      );
    }
  }

// Fonction pour envoyer la position au guide
  void _sendPositionToGuide(Map<String, dynamic> guide, Position position) {
    final message = {
      'type': 'location',
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _showSnackBar("Position partagée avec ${guide['name']}");
  }

  void _navigateToMapWithCoordinates(double latitude, double longitude) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapsPage(
          initialPosition:
              LatLng(latitude, longitude), // Passez les coordonnées ici
        ),
      ),
    );
  }

  // Ajouté : Gestion des notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // Initialiser les notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Afficher une notification
  Future<void> _showNotification(String title, String body) async {
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

  // Exemple : Afficher une notification lors de la sélection d'une destination
  void _onMapTapped(LatLng tappedPoint) {
    setState(() {
      _destination = tappedPoint;
      _markers.add(
        Marker(
          markerId: const MarkerId("destination"),
          position: tappedPoint,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: "Destination"),
        ),
      );

      if (_currentPosition != null) {
        _distanceRemaining = Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              tappedPoint.latitude,
              tappedPoint.longitude,
            ) /
            1000;
      } else {
        _distanceRemaining = null;
      }

      // Afficher une notification
      _showNotification(
        "Nouvelle destination sélectionnée",
        "Latitude: ${tappedPoint.latitude}, Longitude: ${tappedPoint.longitude}",
      );

      _showDestinationDetails(context);
    });
  }

  // Exemple : Afficher une notification en cas de déviation
  void _checkForDeviation() {
    if (_currentPosition != null && _destination != null) {
      final distance = Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            _destination!.latitude,
            _destination!.longitude,
          ) /
          1000;

      if (distance > 1.0) {
        // Seuil de déviation : 1 km
        _showNotification(
          "Déviation détectée",
          "Vous vous êtes écarté de l'itinéraire prévu.",
        );
      }
    }
  }

  // Fonction appelée lors de la création de la carte pour enregistrer son contrôleur
  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

// Fonction pour récupérer et afficher la position actuelle de l'utilisateur
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar("Activez votre GPS pour voir votre position");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar("Permission refusée");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar(
            "Allez dans les paramètres pour autoriser la localisation");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _markers.add(
          Marker(
            markerId: const MarkerId("current_location"),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: "Ma position"),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            onTap: () {
              _showCurrentLocationDetails(
                  context, LatLng(position.latitude, position.longitude));
            },
          ),
        );
      });
      // Mise à jour météo pour la nouvelle position (nouvelle fonctionnalité)
      if (_weatherService != null) {
        _weatherService.fetchWeather(position.latitude, position.longitude);
      }

      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 14.0),
        ),
      );

      print(
          "📌 Appel de _checkDistanceToKesra() après mise à jour de la position");
      _checkDistanceToKesra();
    } catch (e) {
      _showSnackBar("Erreur : ${e.toString()}");
    }
  }

//  Fonction pour rechercher une adresse et l'afficher sur la carte
  Future<void> _searchLocation() async {
    String searchText = _searchController.text.trim();
    if (searchText.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(searchText);

      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng searchPosition = LatLng(location.latitude, location.longitude);

        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(searchText),
              position: searchPosition,
              infoWindow: InfoWindow(title: searchText),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
            ),
          );
        });

        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: searchPosition, zoom: 14.0),
          ),
        );
      } else {
        _showSnackBar("Lieu introuvable !");
      }
    } catch (e) {
      _showSnackBar("Erreur lors de la recherche : ${e.toString()}");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Fonction pour gérer le clic sur la carte et définir la destination
  void _onMapTappede(LatLng tappedPoint) {
    setState(() {
      _destination = tappedPoint;
      _markers.add(
        Marker(
          markerId: const MarkerId("destination"),
          position: tappedPoint,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: "Destination"),
        ),
      );

      // Vérifier si la position actuelle est définie
      if (_currentPosition != null) {
        _distanceRemaining = Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              tappedPoint.latitude,
              tappedPoint.longitude,
            ) /
            1000; // Convertir en km
      } else {
        _distanceRemaining =
            null; // Réinitialiser la distance si la position actuelle n'est pas disponible
      }

      // Afficher les détails de la destination
      _showDestinationDetails(context);
    });
  }

  // Fonction pour afficher les détails de la destination sélectionnée (coordonnées et distance restante)
  void _showDestinationDetails(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? Colors.grey[850]! : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text(
            "Destination sélectionnée",
            style: GoogleFonts.poppins(
              color: textColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Latitude: ${_destination!.latitude}",
                style: GoogleFonts.poppins(
                  color: textColor,
                ),
              ),
              Text(
                "Longitude: ${_destination!.longitude}",
                style: GoogleFonts.poppins(
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _distanceRemaining != null
                    ? "Distance restante : ${_distanceRemaining!.toStringAsFixed(2)} km"
                    : "Distance restante : Non disponible",
                style: GoogleFonts.poppins(
                  color: textColor,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Fermer",
                style: GoogleFonts.poppins(
                  color: Color(0xFF80C000), // Vert
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  //Fonction pour tracer un itinéraire entre la position actuelle et la destination
  Future<void> _drawRoute() async {
    if (_currentPosition == null || _destination == null) {
      _showSnackBar(
          "Veuillez sélectionner une destination et activer la localisation.");
      return;
    }

    const apiKey =
        'AIzaSyDaH6YTETPcQMnNjAFptWwSnjVs_oF31Y0'; // Remplacez par votre clé API Google Directions
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=${_destination!.latitude},${_destination!.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        List<LatLng> points =
            _decodePolyline(data['routes'][0]['overview_polyline']['points']);
        setState(() {
          _polylines.clear(); // Efface les anciennes polylines
          _polylines.add(
            Polyline(
              polylineId: const PolylineId("route"),
              points: points,
              color: Colors.blue,
              width: 5,
            ),
          );
        });
      } else {
        _showSnackBar("Erreur de l'API Directions: ${data['status']}");
      }
    } else {
      _showSnackBar("Erreur HTTP: ${response.statusCode}");
    }
  }

  // Décodage d'une polyligne en liste de coordonnées
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  Future<void> _showCurrentLocationDetails(
      BuildContext context, LatLng position) async {
    // Récupérer les informations météo
    final weatherInfo =
        await _fetchWeatherInfo(position.latitude, position.longitude);

    // Définir les couleurs en fonction du mode sombre
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? Colors.grey[850]! : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text(
            "Détails de la position actuelle",
            style: GoogleFonts.poppins(
              color: textColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Latitude: ${position.latitude}",
                style: GoogleFonts.poppins(
                  color: textColor,
                ),
              ),
              Text(
                "Longitude: ${position.longitude}",
                style: GoogleFonts.poppins(
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              if (weatherInfo != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Météo: ${weatherInfo['weather']}",
                      style: GoogleFonts.poppins(
                        color: textColor,
                      ),
                    ),
                    Text(
                      "Température: ${weatherInfo['temperature']}°C",
                      style: GoogleFonts.poppins(
                        color: textColor,
                      ),
                    ),
                    Text(
                      "Humidité: ${weatherInfo['humidity']}%",
                      style: GoogleFonts.poppins(
                        color: textColor,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  "Impossible de récupérer les informations météo.",
                  style: GoogleFonts.poppins(
                    color: textColor,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Fermer",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF80C000), // Vert
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  //fonction en Dart qui récupère les informations météo
  Future<Map<String, dynamic>?> _fetchWeatherInfo(
      double latitude, double longitude) async {
    const apiKey =
        '67a4b77d36511aa99b34762abd049431'; // Remplacez par votre clé API OpenWeatherMap
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
      } else {
        print(
            "Erreur lors de la récupération des données: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Erreur lors de la récupération des informations météo: $e");
      return null;
    }
  }

  // classe danger
  void _navigateToReportDangerPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReportDangerPage()),
    );
  }

// Définition d'un style de texte réutilisable
  TextStyle _boldTextStyle() {
    return TextStyle(fontWeight: FontWeight.bold);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90, // Hauteur totale des deux barres
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Deuxième barre avec la barre de recherche et les boutons
            Container(
              color: Color(0xFFEEEFF3),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Rechercher un lieu...",
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                  });
                                },
                              )
                            : null,
                      ),
                      onSubmitted: (value) => _searchLocation(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.black),
                    onPressed: _searchLocation,
                  ),
                  IconButton(
                    icon: const Icon(Icons.my_location, color: Colors.black),
                    onPressed: _getCurrentLocation,
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      FiltreUtils.handleFilterSelection(value, (message) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      });
                      // Ajoutez ici toute autre logique nécessaire après la sélection
                    },
                    itemBuilder: (BuildContext context) =>
                        FiltreUtils.buildFilterMenuItems(context),
                    icon: Icon(Icons.filter_list),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            polylines: _polylines,
            myLocationButtonEnabled: false,
            onTap: _onMapTapped,
          ),

          // Barre d'alerte météo (nouveau widget)
          if (_currentWeather != null)
            Positioned(
              top: 70, // Position sous l'AppBar
              left: 16,
              right: 16,
              child: WeatherAlertBar(
                weather: _currentWeather!,
                onTap: _showWeatherDetails,
              ),
            ),
        ],
      ),

      // Conseils de sécurité en bas de l'écran (nouveau widget)
      bottomSheet: _currentWeather?.alerts.isNotEmpty ?? false
          ? SafetyTipsCard(
              advices: SafetyDatabase.getAdvicesForCondition(
                _currentWeather!.condition,
              ),
            )
          : null,
      floatingActionButton: Stack(
        children: [
          // Bouton de danger à gauche
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 20),
              child: FloatingActionButton(
                onPressed: _navigateToReportDangerPage, // Correction
                child: Icon(Icons.warning, color: Colors.white),
                backgroundColor:
                    Colors.red, // Couleur rouge pour indiquer un danger
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 0, bottom: 200),
              child: CustomMenu(
                sharePositionCallback: _sharePositionWithGuide,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
