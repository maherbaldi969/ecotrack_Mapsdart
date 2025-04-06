import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TracerItineraire {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';
  static final Map<String, List<LatLng>> _routeCache = {};

  static Future<void> drawRoute({
    required LatLng origin,
    required LatLng destination,
    required Function(Polyline) addPolyline,
    required String googleApiKey,
    TravelMode mode = TravelMode.driving,
    Set<Polyline>? polylines,
  }) async {
    try {
      final cacheKey = '${origin.latitude},${origin.longitude}_'
          '${destination.latitude},${destination.longitude}_$mode';
      
      // Vérifier le cache
      if (_routeCache.containsKey(cacheKey)) {
        _createPolyline(_routeCache[cacheKey]!, addPolyline);
        return;
      }

      final url = '$_baseUrl?'
          'origin=${origin.latitude},${origin.longitude}&'
          'destination=${destination.latitude},${destination.longitude}&'
          'mode=${mode.toString().split('.').last}&'
          'key=$googleApiKey';

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }

      final data = json.decode(response.body);
      
      if (data['status'] != 'OK') {
        throw Exception('Erreur API: ${data['status']}');
      }

      final points = data['routes'][0]['overview_polyline']['points'];
      final decodedPoints = decodePolyline(points);
      
      // Mettre en cache
      _routeCache[cacheKey] = decodedPoints;
      
      _createPolyline(decodedPoints, addPolyline);

    } catch (e) {
      debugPrint('Erreur lors du tracé de l\'itinéraire: $e');
      rethrow;
    }
  }

  static void _createPolyline(List<LatLng> points, Function(Polyline) addPolyline) {
    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.blue,
      points: points,
      width: 5,
    );
    addPolyline(polyline);
  }

  static List<LatLng> decodePolyline(String encoded) {
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
}

enum TravelMode {
  driving,
  walking,
  bicycling,
  transit
}
