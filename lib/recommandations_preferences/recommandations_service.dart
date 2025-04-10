import 'package:ecotrack/services/shared_preferences_service.dart';
import 'activity_history_service.dart';

class RecommandationsService {
  final SharedPreferencesService _prefs;
  final ActivityHistoryService _history;

  RecommandationsService(this._prefs, this._history);

  Future<List<Map<String, dynamic>>> getPersonalizedRecommandations() async {
    final prefs = await _prefs.getUserPreferences();
    final topTypes = await _history.getTopActivityTypes();
    final recentActivities = await _history.getRecentlyViewed();
    
    // Combinaison des préférences avec historique
    final activityTypes = _combinePreferences(
      (prefs['activityTypes'] as String).split(','),
      topTypes,
      recentActivities.map<String>((a) => a['type'] as String).toList()
    );

    // Calcul des scores pour chaque activité
    final allActivities = await _getAllActivities();
    final scoredActivities = await _scoreActivities(
      allActivities,
      activityTypes,
      prefs['duration'],
      prefs['budget'],
      prefs['language']
    );

    // Tri par score décroissant
    scoredActivities.sort((a, b) => b['score'].compareTo(a['score']));
    
    return scoredActivities.take(10).toList();
  }

  List<String> _combinePreferences(
    List<String> mainTypes,
    List<String> suggestedTypes,
    List<String> recentTypes,
    {double recentWeight = 0.3, double suggestedWeight = 0.2}
  ) {
    final combined = [...mainTypes];
    
    // Ajout des types suggérés avec pondération
    for (final type in suggestedTypes) {
      if (!combined.contains(type)) {
        combined.add(type);
      }
    }
    
    // Ajout des types récents avec plus de poids
    for (final type in recentTypes) {
      if (!combined.contains(type)) {
        combined.add(type);
      } else {
        // Augmente le poids si déjà présent
        combined.add(type); // Duplication = plus de poids
      }
    }
    
    return combined.toSet().toList();
  }

  Future<List<Map<String, dynamic>>> _scoreActivities(
    List<Map<String, dynamic>> activities,
    List<String> preferredTypes,
    String preferredDuration,
    String preferredBudget,
    String preferredLanguage
  ) async {
    return activities.map((activity) {
      double score = 0;
      
      // Score par type d'activité
      if (preferredTypes.contains(activity['type'])) {
        score += 0.4;
      }
      
      // Score par durée
      if (activity['duration'] == preferredDuration) {
        score += 0.2;
      }
      
      // Score par budget
      if (_matchBudget(activity['price'], preferredBudget)) {
        score += 0.2;
      }
      
      // Score par langue
      if (activity['languages']?.contains(preferredLanguage) ?? false) {
        score += 0.2;
      }
      
      return {...activity, 'score': score};
    }).toList();
  }

  bool _matchBudget(String activityPrice, String userBudget) {
    // Logique de correspondance budget
    return true; // Implémenter selon les besoins
  }

  Future<List<Map<String, dynamic>>> _getAllActivities() async {
    // Récupérer toutes les activités disponibles
    return []; // Implémenter la source réelle
  }
}
