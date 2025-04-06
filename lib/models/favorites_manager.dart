import 'package:flutter/foundation.dart';
import 'itinerary.dart';

class FavoritesManager extends ChangeNotifier {
  final List<Itinerary> _favoriteItineraries = [];

  List<Itinerary> get favoriteItineraries => _favoriteItineraries;

  void addToFavorites(Itinerary itinerary) {
    if (!_favoriteItineraries.contains(itinerary)) {
      _favoriteItineraries.add(itinerary);
      notifyListeners(); // Notifie les widgets qui écoutent ce provider
    }
  }

  void removeFromFavorites(Itinerary itinerary) {
    _favoriteItineraries.remove(itinerary);
    notifyListeners(); // Mise à jour de l'UI
  }

  bool isFavorite(Itinerary itinerary) {
    return _favoriteItineraries.contains(itinerary);
  }
}
