import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weather/weather.dart';

class TrackingScreen extends StatefulWidget {
  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  Position? _currentPosition;
  double? _altitude;
  double? _distanceRemaining;
  String _weatherInfo = "Chargement...";
  String _windSpeedInfo = "Chargement...";
  LatLng? _destination;
  Set<Marker> _markers = {};
  UniqueKey _mapKey = UniqueKey();

  final WeatherFactory _weatherFactory =
  WeatherFactory("67a4b77d36511aa99b34762abd049431");

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackbar("Activez la localisation pour continuer.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackbar("La permission de localisation est requise.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackbar("Les permissions de localisation sont refusées définitivement.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentPosition = position;
        _altitude = position.altitude;
        if (_destination != null) {
          _distanceRemaining = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              _destination!.latitude,
              _destination!.longitude) /
              1000;
        }
      });

      _getWeather(position.latitude, position.longitude);
    } catch (e) {
      print("Erreur lors de la récupération de la position : $e");
    }
  }

  Future<void> _getWeather(double lat, double lon) async {
    try {
      Weather weather = await _weatherFactory.currentWeatherByLocation(lat, lon);
      String? description = weather.weatherDescription;
      double? temperature = weather.temperature?.celsius;
      double? windSpeed = weather.windSpeed;

      Map<String, String> traduction = {
        "clear sky": "Ciel dégagé",
        "few clouds": "Quelques nuages",
        "scattered clouds": "Nuages épars",
        "broken clouds": "Nuages fragmentés",
        "shower rain": "Averses",
        "rain": "Pluie",
        "thunderstorm": "Orage",
        "snow": "Neige",
        "mist": "Brouillard",
      };

      String descriptionFr = traduction[description?.toLowerCase()] ?? description ?? "Inconnu";

      setState(() {
        _weatherInfo = "${temperature?.toStringAsFixed(1)}°C, $descriptionFr";
        _windSpeedInfo = "${windSpeed?.toStringAsFixed(1) ?? 'N/A'} m/s";
      });
    } catch (e) {
      print("Erreur lors de la récupération de la météo : $e");
      setState(() {
        _weatherInfo = "Impossible de récupérer la météo";
        _windSpeedInfo = "Impossible de récupérer la vitesse du vent";
      });
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600])),
            SizedBox(height: 5),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("elguid.com", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color(0xFF80C000),
        centerTitle: true,
        elevation: 5,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard("Météo", _weatherInfo),
                  _buildInfoCard("Vent", _windSpeedInfo),
                  _buildInfoCard("Altitude", "${_altitude?.toStringAsFixed(1) ?? 'Chargement...'} m"),
                  _buildInfoCard("Distance restante", "${_distanceRemaining?.toStringAsFixed(2) ?? 'Chargement...'} km"),
                  SizedBox(height: 20),
                  Expanded(
                    child: _currentPosition == null
                        ? Center(child: CircularProgressIndicator())
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GoogleMap(
                        key: _mapKey,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                          zoom: 12,
                        ),
                        markers: _markers,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF80C000),
        onPressed: _getCurrentLocation,
        child: Icon(Icons.my_location, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
