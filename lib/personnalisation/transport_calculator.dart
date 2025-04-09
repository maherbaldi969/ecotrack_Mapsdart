import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../models/transport.dart';

class TransportCalculator {
  static Future<Transport> calculateTransport(
    Activity from,
    Activity to, {
    String mode = 'walking',
  }) async {
    // Calcul de distance (simulé - à remplacer par une vraie API)
    final distance = _calculateDistance(from.location, to.location);
    final duration = _estimateDuration(distance, mode);
    
    return Transport(
      from: from,
      to: to,
      distance: distance,
      duration: duration,
      mode: mode,
    );
  }

  static double _calculateDistance(String loc1, String loc2) {
    // Simulation - en production utiliser une API comme Google Maps
    return 5.0; // km
  }

  static Duration _estimateDuration(double distance, String mode) {
    switch (mode) {
      case 'walking':
        return Duration(minutes: (distance * 15).round());
      case 'driving':
        return Duration(minutes: (distance * 2).round());
      case 'public':
        return Duration(minutes: (distance * 5).round());
      default:
        return Duration(minutes: (distance * 10).round());
    }
  }

  static List<String> get availableModes => 
      ['walking', 'driving', 'public'];
}
