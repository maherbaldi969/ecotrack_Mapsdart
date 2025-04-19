import 'recommandations_service.dart';
import '../models/user_preferences.dart'; // Importing UserPreferences

class Recommendation {
  final RecommandationsService _service;

  Recommendation(this._service); 

  Future<List<Map<String, dynamic>>> genererRecommendation(UserPreferences userPreferences) async {
    // Use user preferences to generate recommendations
    return await _service.getPersonalizedRecommandations();
  }

  void afficherRecommendation(List<Map<String, dynamic>> recommendations) {
    // Display the recommendations (this could be a print statement or UI update)
    for (var recommendation in recommendations) {
      print('Recommendation: ${recommendation['type']} with score: ${recommendation['score']}');
    }
  }
}
