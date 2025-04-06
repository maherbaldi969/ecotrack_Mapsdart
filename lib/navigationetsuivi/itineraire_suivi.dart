import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapsPage1 extends StatefulWidget {
  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage1> {
  GoogleMapController? mapController;
  LatLng? _currentPosition;
  LatLng? _destination;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  final String googleApiKey = "AIzaSyD3AQvCANZzbsOgB2oanuH5UGTUIaCNJqk"; // Remplace avec ta clé API

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar("Permission de localisation refusée");
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showSnackBar("Permission bloquée. Modifiez-la dans les paramètres.");
      return;
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _updateMarker("current_location", _currentPosition!, Colors.blue, "Ma position actuelle");
      mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _currentPosition!, zoom: 14.0)));
    });
  }

  void _updateMarker(String markerId, LatLng position, Color color, String title) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == markerId);
      _markers.add(Marker(
        markerId: MarkerId(markerId),
        position: position,
        infoWindow: InfoWindow(title: title),
        icon: BitmapDescriptor.defaultMarkerWithHue(color == Colors.blue ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueRed),
      ));
    });
  }

  void _onMapTapped(LatLng tappedPoint) {
    setState(() {
      _destination = tappedPoint;
      _updateMarker("destination", _destination!, Colors.red, "Destination");
    });
    _drawRoute();
  }

  Future<void> _drawRoute() async {
    if (_currentPosition == null || _destination == null) {
      _showSnackBar("Veuillez sélectionner une destination.");
      return;
    }

    _polylines.clear();

    print("Début de la requête d'itinéraire...");
    print("Position actuelle: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}");
    print("Destination: ${_destination!.latitude}, ${_destination!.longitude}");

    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey,
        PointLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        PointLatLng(_destination!.latitude, _destination!.longitude),
        travelMode: TravelMode.walking,
      );

      print("Réponse de l'API Directions: ${result.status}");
      print("Message d'erreur: ${result.errorMessage}");

      if (result.status == "OK" && result.points.isNotEmpty) {
        List<LatLng> polylineCoordinates = result.points.map(
              (point) => LatLng(point.latitude, point.longitude),
        ).toList();

        setState(() {
          _polylines.add(Polyline(
            polylineId: PolylineId("route"),
            color: Colors.blue,
            width: 5,
            points: polylineCoordinates,
          ));
        });
        _showSnackBar("Itinéraire tracé avec succès !");
      } else {
        _showSnackBar("Aucun itinéraire trouvé. Vérifiez l'API ou changez l'itinéraire.");
      }
    } catch (e) {
      print("Erreur lors de la requête d'itinéraire: $e");
      _showSnackBar("Erreur lors de la requête d'itinéraire. Vérifiez votre connexion Internet.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Carte des Itinéraires"), backgroundColor: Colors.green),
      body: GoogleMap(
        onMapCreated: (controller) => mapController = controller,
        initialCameraPosition: CameraPosition(target: LatLng(36.9541, 8.7586), zoom: 10.0),
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: true,
        onTap: _onMapTapped,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildFloatingActionButton(Icons.my_location, Colors.green, _getCurrentLocation),
          SizedBox(height: 10),
          _buildFloatingActionButton(Icons.directions, Colors.blue, _drawRoute),
          SizedBox(height: 10),
          _buildFloatingActionButton(Icons.report_problem, Colors.red, _navigateToReportPage),
        ],
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton(IconData icon, Color color, VoidCallback onPressed) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: Icon(icon),
      backgroundColor: color,
    );
  }

  void _navigateToReportPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ReportDangerPage()));
  }
}

class ReportDangerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signaler un Danger")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: "Description du danger")),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Danger signalé avec succès !")));
                Navigator.pop(context);
              },
              child: Text("Envoyer"),
            ),
          ],
        ),
      ),
    );
  }
}