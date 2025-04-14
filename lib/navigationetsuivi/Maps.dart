import 'package:flutter/material.dart';
import 'package:ecotrack/services/notifications_service.dart';
import 'package:ecotrack/services/offline_map_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/services.dart';
import 'data/tracer_itinéraire.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'DangerPage.dart';
import 'dart:async'; // Ajoutez cette ligne
import 'dart:math'; // For min/max functions
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
import 'data/weather_utils.dart';
import 'package:latlong2/latlong.dart' as latlong2;

class LocationAlerts {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Suivi de la position en temps réel
  void trackLocation(latlong2.LatLng destination) {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Mettre à jour la position tous les 10 mètres
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      final currentLocation =
          latlong2.LatLng(position.latitude, position.longitude);
      final distance = _calculateDistance(currentLocation, destination);

      // Vérifier si l'utilisateur s'écarte de l'itinéraire
      if (distance > 100) {
        // 100 mètres de déviation
        NotificationsService.showNotification(
          title: 'Déviation de l\'itinéraire',
          body: 'Vous vous êtes écarté de l\'itinéraire prévu.',
        );
      }

      // Vérifier si l'utilisateur est immobile
      if (position.speed < 1) {
        // Vitesse inférieure à 1 m/s
        NotificationsService.showNotification(
          title: 'Difficulté détectée',
          body: 'Vous semblez être immobile depuis un moment.',
        );
      }
    });
  }

  // Calculer la distance entre deux points (en mètres)
  double _calculateDistance(latlong2.LatLng point1, latlong2.LatLng point2) {
    final latlong2.Distance distance = latlong2.Distance();
    return distance(point1, point2);
  }
}

class MapsPage extends StatefulWidget {
  @override
  _MapsPageState createState() => _MapsPageState();
  final LatLng? initialPosition; // Ajoutez ce paramètre

  // Ajoutez un constructeur pour accepter initialPosition
  MapsPage({this.initialPosition});
}

class _MapsPageState extends State<MapsPage> {
  List<Map<String, dynamic>> favoris = [];
  //  Déclaration des variables pour la carte, les marqueurs et les itinéraires
  GoogleMapController? mapController;
  final LatLng _center = const LatLng(36.9541, 8.7586);
  final LatLng _bizerteItineraryLocation = const LatLng(37.2744, 9.8739);
  final LatLng _center_kesra = const LatLng(35.8136, 9.3644);
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {}; //trajet
  TextEditingController _searchController = TextEditingController();
  final List<String> _searchHints = [
    "Rechercher un lieu",
    "Rechercher un guide",
    "Rechercher un hébergement"
  ];
  int _currentHintIndex = 0;
  Timer? _hintAnimationTimer;
  LatLng? _destination; // Destination sélectionnée par l'utilisateur
  double? _distanceRemaining; // Distance restante en kilomètres
  Position? _currentPosition; // Position actuelle de l'utilisateur
  bool _alertShown = false;
  final LatLng _defaultCenter =
      const LatLng(36.9541, 8.7586); // Centre par défaut
  LatLng? _initialCameraPosition; // Position initiale de la caméra
  late final WeatherService _weatherService = WeatherService();
  late final AlertService _alertService =
      AlertService(FlutterLocalNotificationsPlugin());
  final LocationAlerts _locationAlerts = LocationAlerts();
  StreamSubscription<WeatherData>? _weatherSubscription;
  WeatherData? _currentWeather;
  bool _isOnline = true;
  bool _isOfflineMapAvailable = false;
  String? _currentOfflineMapRegion;
  Position? _lastPosition;
  StreamSubscription<Position>? _positionStream;
  bool _isTracking = false;
  bool _showDownloadOption = false;
  bool _isDownloading = false;
  // 1. Dans votre classe _MapsPageState, ajoutez ces constantes pour les catégories
  static const String _categoryAll = "Tous";
  static const String _categoryHiking = "Randonnées";
  static const String _categoryGuides = "Guides";
  static const String _categoryAccommodation = "Hébergement";

  @override
  void initState() {
    super.initState();
    _initialCameraPosition = widget.initialPosition ?? _defaultCenter;
    _startHintAnimation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAppServices();
    });
  }

  Future<void> _initializeAppServices() async {
    try {
      // 1. Initialize notifications service
      await NotificationsService.initialize();

      // Initialize offline maps
      _isOfflineMapAvailable =
          await OfflineMapService.isMapDownloaded('current_region');
      if (_isOfflineMapAvailable) {
        _currentOfflineMapRegion =
            await OfflineMapService.getMapPath('current_region');
      } else if (_isOnline) {
        // Show download option in UI
        setState(() {
          _showDownloadOption = true;
        });
      }

      // 2. Check and request location permissions
      final locationStatus = await Permission.locationWhenInUse.status;
      if (!locationStatus.isGranted) {
        await Permission.locationWhenInUse.request();
      }

      // 3. Load initial data if permissions granted
      if (locationStatus.isGranted) {
        _addItineraryMarker();
        await _getCurrentLocation();

        loadMarkersHebergements(
          _markers,
          context,
          (heb) => showCenteredDialog(
            heb,
            context,
            (nom) => reserverGuide(nom, context),
            (heb) => ajouterAuxFavoris(heb, context),
          ),
        );

        loadMarkersGuides(_markers, context, _showGuideDialogWrapper);
        loadMarkersRandonnees(_markers, context, _showRandoDialogWrapper);

        // 4. Initialize weather monitoring
        final subscription = await WeatherUtils.initializeWeatherMonitoring(
          _weatherService,
          _alertService,
          _currentPosition,
        );

        if (mounted && subscription is StreamSubscription<WeatherData>) {
          setState(() => _weatherSubscription = subscription);
        }

        // 5. Start periodic checks
        if (mounted) {
          Timer.periodic(Duration(seconds: 15), (Timer timer) {
            if (mounted) _checkDistanceToKesra();
          });
        }
      }

      // 6. Check connectivity
      await _checkConnectivity();
    } catch (e) {
      debugPrint('Initialization error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Initialization error: ${e.toString()}')),
        );
      }
    }
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
    _weatherSubscription?.cancel(); // Annule l'abonnement météo
    _weatherService.dispose();
    _positionStream?.cancel(); // Si vous avez un stream de position
    _hintAnimationTimer?.cancel();
    super.dispose();
  }

  void _startHintAnimation() {
    _hintAnimationTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          // First fade out
          Future.delayed(Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                // Then change text and fade in
                _currentHintIndex =
                    (_currentHintIndex + 1) % _searchHints.length;
              });
            }
          });
        });
      }
    });
  }

//Mettre à jour _showWeatherDetails :
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
            // Utilisation de la nouvelle fonction de construction de ligne
            WeatherUtils.buildWeatherDetailRow(
                context,
                Icons.thermostat,
                'Température',
                '${_currentWeather!.temperature.toStringAsFixed(1)}°C'),
            WeatherUtils.buildWeatherDetailRow(
              context,
              Icons.water_drop,
              'Humidité',
              '${_currentWeather!.humidity}%',
            ),
            WeatherUtils.buildWeatherDetailRow(
              context,
              Icons.air,
              'Vent',
              '${_currentWeather!.windSpeed.toStringAsFixed(1)} km/h',
            ),
          ],
        ),
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
      "description": "Un superbe itinéraire longeant le littoral de Bizerte...",
      "guides_available": [
        {
          "name": "Mohamed",
          "rating": 4.8,
          "languages": ["Français", "Arabe"]
        },
        {
          "name": "Samira",
          "rating": 4.9,
          "languages": ["Anglais", "Arabe"]
        }
      ],
      "attractions": [
        {"name": "Phare Cap Blanc", "distance": "2.5km"},
        {"name": "Plage Sidi Salem", "distance": "4km"}
      ],
      "save_for_offline": false
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
            if (itinerary['guides_available'].isNotEmpty)
              TextButton(
                onPressed: () async {
                  final selectedGuide =
                      await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatListScreen(
                        guides: itinerary['guides_available'],
                        isSelectingGuide: true,
                      ),
                    ),
                  );

                  if (selectedGuide != null && mounted) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            user: selectedGuide['name'],
                            messages: [], // TODO: Passer la liste réelle des messages
                            onSendMessage: (message, sender) {
                              print("Message envoyé: $message");
                            },
                            onLocationMessageTap: (latitude, longitude) {
                              _navigateToMapWithCoordinates(latitude, longitude);
                            },
                          ),
                        ),
                      );
                  }
                },
                child: const Text("Réserver un guide"),
              ),
            TextButton(
              onPressed: () {
                setState(() {
                  itinerary['save_for_offline'] = true;
                  _saveItineraryOffline(itinerary);
                });
                Navigator.pop(context);
              },
              child: const Text("Enregistrer hors ligne"),
            ),
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
        builder: (context) => ChatListScreen(
          guides: [], // Passing empty list since we don't have guide data here
          isSelectingGuide: true,
        ),
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
            messages: [], // TODO: Passer la liste réelle des messages
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

  // Utiliser NotificationsService pour les notifications
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
      NotificationsService.showLocationNotification(
        title: "Nouvelle destination sélectionnée",
        body: "Position",
        latitude: tappedPoint.latitude,
        longitude: tappedPoint.longitude,
      );

      // Start tracking location to destination
      _locationAlerts.trackLocation(
          latlong2.LatLng(tappedPoint.latitude, tappedPoint.longitude));

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
        NotificationsService.showNotification(
          title: "Déviation détectée",
          body: "Vous vous êtes écarté de l'itinéraire prévu.",
        );
      }
    }
  }

  // Fonction appelée lors de la création de la carte pour enregistrer son contrôleur
  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;

      final initialZoom = widget.initialPosition != null ? 15.0 : 11.0;
      final targetPosition = widget.initialPosition ?? _center;

      // Ajouter un marqueur si position initiale fournie
      if (widget.initialPosition != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId("shared_position"),
            position: widget.initialPosition!,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: const InfoWindow(title: "Position partagée"),
          ),
        );
      }

      // Désactiver l'animation pour éviter le déplacement de l'écran
      controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: targetPosition,
            zoom: initialZoom,
          ),
        ),
      );
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

  // Fonction pour rechercher une adresse et l'afficher sur la carte
  Future<void> _searchLocation() async {
    String searchText = _searchController.text.trim();
    if (searchText.isEmpty) {
      _showSnackBar("Veuillez entrer un lieu à rechercher");
      return;
    }

    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );

      List<Location> locations = await locationFromAddress(searchText);

      // Fermer l'indicateur de chargement
      Navigator.of(context).pop();

      if (locations.isEmpty) {
        _showSnackBar("Aucun résultat trouvé pour '$searchText'");
        return;
      }

      Location location = locations.first;
      LatLng searchPosition = LatLng(location.latitude, location.longitude);

      setState(() {
        // Supprimer l'ancien marqueur de recherche s'il existe
        _markers
            .removeWhere((marker) => marker.markerId.value == "search_result");

        // Ajouter le nouveau marqueur
        _markers.add(
          Marker(
            markerId: const MarkerId("search_result"),
            position: searchPosition,
            infoWindow: InfoWindow(
              title: searchText,
              snippet: "Destination recherchée",
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );

        // Définir comme destination
        _destination = searchPosition;
        _distanceRemaining = _currentPosition != null
            ? Geolocator.distanceBetween(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                  searchPosition.latitude,
                  searchPosition.longitude,
                ) /
                1000
            : null;
      });

      // Centrer la carte sur le résultat
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: searchPosition, zoom: 14.0),
        ),
      );

      // Afficher les détails de la destination
      _showDestinationDetails(context);
    } catch (e) {
      // Fermer l'indicateur de chargement en cas d'erreur
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      _showSnackBar("Erreur lors de la recherche : ${e.toString()}");
      debugPrint("Search error: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void reserverGuide(String hebergement, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Réservation d'un guide pour $hebergement"),
      ),
    );
  }

  void ajouterAuxFavoris(Map<String, dynamic> heb, BuildContext context) {
    if (!favoris.any((element) => element["nom"] == heb["nom"])) {
      favoris.add(heb);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ajouté aux favoris: ${heb["nom"]}"),
        ),
      );
    }
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
            if (!_isOnline && _isOfflineMapAvailable)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.offline_bolt, color: Colors.orange),
                      SizedBox(width: 5),
                      Text('Mode hors-ligne',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // Fonction pour tracer un itinéraire entre la position actuelle et la destination
  Future<void> _drawRoute() async {
    if (_currentPosition == null) {
      _showSnackBar(
          "Veuillez activer la localisation pour tracer un itinéraire.");
      return;
    }

    if (_destination == null) {
      _showSnackBar(
          "Veuillez d'abord sélectionner une destination en cliquant sur la carte.");
      return;
    }

    try {
      setState(() {
        _polylines.clear(); // Effacer les itinéraires précédents
      });

      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );

      await TracerItineraire.drawRoute(
        origin: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        destination: _destination!,
        addPolyline: (polyline) {
          setState(() {
            _polylines.add(polyline);
          });
        },
        googleApiKey: 'AIzaSyDaH6YTETPcQMnNjAFptWwSnjVs_oF31Y0',
      );

      // Zoom pour afficher l'itinéraire complet
      if (mapController != null) {
        final bounds = LatLngBounds(
          southwest: LatLng(
            min(_currentPosition!.latitude, _destination!.latitude),
            min(_currentPosition!.longitude, _destination!.longitude),
          ),
          northeast: LatLng(
            max(_currentPosition!.latitude, _destination!.latitude),
            max(_currentPosition!.longitude, _destination!.longitude),
          ),
        );
        mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
      }

      // Fermer l'indicateur de chargement
      Navigator.of(context).pop();

      // Afficher les informations de l'itinéraire
      _showRouteInfo();
    } catch (e) {
      // Fermer l'indicateur de chargement en cas d'erreur
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      _showSnackBar("Erreur lors du tracé de l'itinéraire: ${e.toString()}");
      debugPrint("Route drawing error: $e");
    }
  }

  // Afficher les informations de l'itinéraire (distance et durée estimée)
  void _showRouteInfo() {
    if (_currentPosition == null || _destination == null) return;

    final distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          _destination!.latitude,
          _destination!.longitude,
        ) /
        1000; // Convertir en kilomètres

    // Estimation de la durée (en minutes) - 5 min par km en voiture
    final estimatedDuration = (distance * 5).toInt();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Informations de l'itinéraire"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Distance: ${distance.toStringAsFixed(1)} km"),
            Text("Durée estimée: $estimatedDuration minutes"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
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

//Mettre à jour _showCurrentLocationDetails :
  Future<void> _showCurrentLocationDetails(
      BuildContext context, LatLng position) async {
    // Utilisation de la nouvelle fonction de récupération météo
    final weatherInfo = await WeatherUtils.fetchWeatherInfo(
        position.latitude, position.longitude);

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
            style: GoogleFonts.poppins(color: textColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Latitude: ${position.latitude}",
                style: GoogleFonts.poppins(color: textColor),
              ),
              Text(
                "Longitude: ${position.longitude}",
                style: GoogleFonts.poppins(color: textColor),
              ),
              const SizedBox(height: 10),
              if (weatherInfo != null) ...[
                Text(
                  "Météo: ${weatherInfo['weather']}",
                  style: GoogleFonts.poppins(color: textColor),
                ),
                Text(
                  "Température: ${weatherInfo['temperature']}°C",
                  style: GoogleFonts.poppins(color: textColor),
                ),
                Text(
                  "Humidité: ${weatherInfo['humidity']}%",
                  style: GoogleFonts.poppins(color: textColor),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Fermer",
                style: GoogleFonts.poppins(color: Color(0xFF80C000)),
              ),
            ),
          ],
        );
      },
    );
  }

  //fonction en Dart qui récupère les informations météo
  // classe danger
  void _showGuideSelection(List<dynamic> guides) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sélectionner un guide'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: guides
              .map((guide) => ListTile(
                    leading: Icon(Icons.person),
                    title: Text(guide['name']),
                    subtitle: Text(
                        '${guide['rating']} ⭐ - ${guide['languages'].join(', ')}'),
                    onTap: () {
                      Navigator.pop(context);
                      _contacterGuideWrapper(guide['name']);
                    },
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveItineraryOffline(Map<String, dynamic> itinerary) async {
    try {
      await OfflineMapService.saveItinerary(itinerary);
      _showSnackBar('Itinéraire enregistré pour consultation hors ligne');
    } catch (e) {
      _showSnackBar('Erreur lors de l\'enregistrement: ${e.toString()}');
    }
  }

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
                        hintText: _searchHints[_currentHintIndex],
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
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
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
                  IconButton(
                    icon: const Icon(Icons.directions, color: Colors.black),
                    onPressed: _drawRoute,
                    tooltip: 'Tracer itinéraire',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barre de catégories
          Container(
            height: 50,
            color: Color(0xFFEEEFF3), // Couleur grise fixe
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(width: 8),
                  _buildCategoryButton(_categoryAll, () {
                    _filterByCategory(_categoryAll);
                  }),
                  _buildCategoryButton(_categoryHiking, () {
                    _filterByCategory(_categoryHiking);
                  }),
                  _buildCategoryButton(_categoryGuides, () {
                    _filterByCategory(_categoryGuides);
                  }),
                  _buildCategoryButton(_categoryAccommodation, () {
                    _filterByCategory(_categoryAccommodation);
                  }),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 11.0,
                  ),
                  markers: _isFilterActive ? _filteredMarkers : _markers,
                  myLocationEnabled: true,
                  polylines: _polylines,
                  myLocationButtonEnabled: false,
                  onTap: _onMapTapped,
                  onCameraMoveStarted: () {
                    if (!_isOnline && !_isOfflineMapAvailable) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Mode hors-ligne - zone limitée'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),

                // Barre d'alerte météo
                if (_currentWeather != null &&
                    _currentWeather!.alerts.isNotEmpty)
                  Positioned(
                    top: 70,
                    left: 16,
                    right: 16,
                    child: WeatherAlertBar(
                      weather: _currentWeather!,
                      onTap: _showWeatherDetails,
                    ),
                  ),
              ],
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
                onPressed: _navigateToReportDangerPage,
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

  Widget _buildCategoryButton(String text, VoidCallback onPressed) {
    final isActive = _activeFilter == text;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: () {
          onPressed();
          setState(() {
            _activeFilter = text;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Color(0xFF80C000) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // Variables pour le filtrage
  Set<Marker> _filteredMarkers = {};
  bool _isFilterActive = false;
  String _activeFilter = _categoryAll; // Pour suivre le filtre actif

  void _filterByCategory(String category) {
    setState(() {
      _activeFilter = category;

      if (category == _categoryAll) {
        _isFilterActive = false;
        return;
      }

      _isFilterActive = true;
      _filteredMarkers = {};

      switch (category) {
        case _categoryHiking:
          loadMarkersRandonnees(
              _filteredMarkers, context, _showRandoDialogWrapper);
          break;

        case _categoryGuides:
          loadMarkersGuides(_filteredMarkers, context, _showGuideDialogWrapper);
          break;

        case _categoryAccommodation:
          loadMarkersHebergements(
              _filteredMarkers,
              context,
              (heb) => showCenteredDialog(
                  heb,
                  context,
                  (nom) => reserverGuide(nom, context),
                  (heb) => ajouterAuxFavoris(heb, context)));
          break;
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _isFilterActive = false;
    });
  }

  Set<Marker> get _currentMarkers {
    return _isFilterActive ? _filteredMarkers : _markers;
  }
}
