import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'review.dart';

class Itinerary {
  final String name;
  final double distance;
  final String difficulty;
  final int duration;
  final double altitude;
  final LatLng location;
  final List<Review> reviews;  // Liste des avis

  Itinerary({
    required this.name,
    required this.distance,
    required this.difficulty,
    required this.duration,
    required this.altitude,
    required this.location,
    this.reviews = const [],  // Initialisation par défaut
  });

  // Ajouter un avis
  void addReview(Review review) {
    reviews.add(review);
  }
}
