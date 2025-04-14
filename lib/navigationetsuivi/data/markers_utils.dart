import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../alerts/weather_data.dart';
import '../../chat/chat_screen.dart';
import 'hebergements_data.dart';
import 'guides_data.dart';
import 'randonnees_data.dart';

// Fonctions pour les hébergements
void loadMarkersHebergements(Set<Marker> markers, BuildContext context,
    Function(Map<String, dynamic>) showDialogFunction) {
  for (var heb in hebergements) {
    markers.add(
      Marker(
        markerId: MarkerId(heb["nom"]),
        position: LatLng(heb["lat"], heb["lng"]),
        infoWindow: InfoWindow(
          title: heb["nom"],
          snippet: "Hébergement en Nord-Ouest Tunisie",
        ),
        consumeTapEvents: true,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        onTap: () {
          showDialogFunction(heb);
        },
      ),
    );
  }
}

void showCenteredDialog(
    Map<String, dynamic> heb,
    BuildContext context,
    Function(String) reserverGuide,
    Function(Map<String, dynamic>) ajouterAuxFavoris) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon:
                          Icon(Icons.close, color: Color(0xFF80C000), size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Text(
                    heb["nom"],
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Localisation: Lat ${heb["lat"]}, Lng ${heb["lng"]}",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      reserverGuide(heb["nom"]);
                    },
                    child: Text("Réserver un Hotel"),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

// Fonctions pour les guides
void loadMarkersGuides(Set<Marker> markers, BuildContext context,
    Function(Map<String, dynamic>) showDialogFunction) {
  for (var guide in guides) {
    markers.add(
      Marker(
        markerId: MarkerId(guide["nom"]),
        position: LatLng(guide["lat"], guide["lng"]),
        infoWindow: InfoWindow(
          title: guide["nom"],
          snippet: "Guide local disponible",
        ),
        consumeTapEvents: true,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        onTap: () {
          showDialogFunction(guide);
        },
      ),
    );
  }
}

void showGuideDialog(Map<String, dynamic> guide, BuildContext context,
    Function(String) contacterGuide) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon:
                          Icon(Icons.close, color: Color(0xFF80C000), size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Text(
                    guide["nom"],
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Localisation: Lat ${guide["lat"]}, Lng ${guide["lng"]}",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            user: guide["nom"],
                            messages: [], // TODO: Passer la liste réelle des messages
                            onSendMessage: (message, sender) {
                              // Handle message sending
                              print("Message envoyé: $message");
                            },
                            onLocationMessageTap: (latitude, longitude) {
                              // Handle location message tap
                            },
                          ),
                        ),
                      );
                    },
                    child: Text("Contacter le guide"),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

// Fonctions pour les randonnées
void loadMarkersRandonnees(Set<Marker> markers, BuildContext context,
    Function(Map<String, dynamic>) showDialogFunction) {
  for (var rando in randonnees) {
    markers.add(
      Marker(
        markerId: MarkerId(rando["nom"]),
        position: LatLng(rando["lat"], rando["lng"]),
        infoWindow: InfoWindow(
          title: rando["nom"],
          snippet: "Randonnée disponible ici",
        ),
        consumeTapEvents: true,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        onTap: () {
          showDialogFunction(rando);
        },
      ),
    );
  }
}

void showRandonneesDialog(Map<String, dynamic> rando, BuildContext context,
    Function(String) afficherDetailsFunction) {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final Color backgroundColor = isDarkMode ? Colors.grey[850]! : Colors.white;
  final Color textColor = isDarkMode ? Colors.white : Colors.black;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: backgroundColor,
        title: Text(
          rando["nom"],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/intinaire.jpeg', width: 300),
            const SizedBox(height: 8),
            Text(
              "Localisation: Lat ${rando["lat"]}, Lng ${rando["lng"]}",
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 8),
            const Text("⭐ 4.8/5 - 120 avis"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                afficherDetailsFunction(rando["nom"]);
              },
              child: const Text("Voir détails"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Fermer",
              style: TextStyle(color: Color(0xFF80C000)),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> afficherDetailsRandonnee(String nom) async {
  String url = "https://www.elguid.com/Y008/2024/05/06/art_hammam-zouakra/";
  Uri uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw "Impossible d'ouvrir le lien : $url";
  }
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

void reserverGuide(String hebergement, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Réservation d'un guide pour $hebergement"),
    ),
  );
}

void contacterGuide(String guide, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Contact en cours avec $guide"),
    ),
  );
}

// Fonctions pour les itinéraires et alertes
void addItineraryMarker(Set<Marker> markers, LatLng bizerteItineraryLocation,
    BuildContext context) {
  markers.add(
    Marker(
      markerId: const MarkerId("itinerary_bizerte"),
      position: bizerteItineraryLocation,
      infoWindow: const InfoWindow(
        title: "Randonnée Cap Blanc",
        snippet: "Un itinéraire magnifique au nord de Bizerte",
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      onTap: () {
        showItineraryDetails(context);
      },
    ),
  );
}

void showItineraryDetails(BuildContext context) {
  final Map<String, String> itinerary = {
    "title": "Randonnée Cap Blanc",
    "image_url": "https://example.com/images/cap_blanc.jpg",
    "distance": "10.5 km",
    "duration": "2h 30min",
    "altitude": "250 m",
    "description": "Un superbe itinéraire longeant le littoral de Bizerte",
  }..removeWhere((key, value) => value == null);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(itinerary["title"] ?? 'Détails itinéraire'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/capbizerte.jpeg', width: 300),
          const SizedBox(height: 8),
          Text(itinerary["description"] ?? 'Description non disponible'),
          const SizedBox(height: 8),
          const Text("⭐ 4.8/5 - 120 avis"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/itineraries'),
            child: const Text("Voir détails"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Fermer"),
        ),
      ],
    ),
  );
}

void showAlert(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

void checkDistanceToKesra(
    BuildContext context, Position? currentPosition, LatLng centerKesra) {
  if (currentPosition == null) return;

  final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        centerKesra.latitude,
        centerKesra.longitude,
      ) /
      1000;

  if (distance >= 5 && distance <= 20) {
    showAlert(
      context,
      "Vous êtes proche de Kesra",
      "Il reste ${distance.toStringAsFixed(2)} km pour atteindre Kesra.",
    );
  }
}

Widget buildWeatherDetailRow(
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

void showWeatherDetails(BuildContext context, WeatherData? weather) {
  if (weather == null) return;

  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Détails météorologiques',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          buildWeatherDetailRow(context, Icons.thermostat, 'Température',
              '${weather.temperature.toStringAsFixed(1)}°C'),
          buildWeatherDetailRow(
              context, Icons.water_drop, 'Humidité', '${weather.humidity}%'),
        ],
      ),
    ),
  );
}

List<Map<String, dynamic>> favoris = [];
