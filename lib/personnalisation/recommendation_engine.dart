import '../models/activity.dart';
import '../models/user_preferences.dart';

class RecommendationEngine {
  final List<Activity> _allActivities;
  final UserPreferences _preferences;

  RecommendationEngine(this._allActivities, this._preferences);

  List<Activity> getRecommendedActivities() {
    return _allActivities.where((activity) {
      // Vérification des tags d'intérêt
      final hasMatchingTags = activity.tags.isNotEmpty && 
          _preferences.interestTags.isNotEmpty &&
          activity.tags.any((tag) => _preferences.interestTags.contains(tag));
      
      // Vérification du budget
      final withinBudget = activity.price <= _preferences.maxBudget;
      
      // Vérification de la durée
      final fitsDuration = activity.duration <= _preferences.availableTime;
      
      // Vérification de la plage horaire
      final fitsTimeSlot = activity.startTime == null ||
          (activity.startTime!.hour >= _preferences.preferredStartTime.hour &&
           activity.startTime!.hour <= _preferences.preferredEndTime.hour);

      return hasMatchingTags && withinBudget && fitsDuration && fitsTimeSlot;
    }).toList();
  }

  List<List<Activity>> generateProgramSuggestions() {
    final recommended = getRecommendedActivities();
    return _generateCombinations(recommended, _preferences.availableTime);
  }

  List<List<Activity>> _generateCombinations(
    List<Activity> activities, 
    double remainingTime,
    [List<Activity> current = const [], 
     int startIndex = 0]
  ) {
    List<List<Activity>> results = [];
    
    for (int i = startIndex; i < activities.length; i++) {
      final activity = activities[i];
      if (activity.duration <= remainingTime) {
        var newCurrent = List<Activity>.from(current)..add(activity);
        results.add(newCurrent);
        
        results.addAll(_generateCombinations(
          activities,
          remainingTime - activity.duration,
          newCurrent,
          i + 1
        ));
      }
    }
    
    return results;
  }
}
