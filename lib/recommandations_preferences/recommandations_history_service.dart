import 'package:shared_preferences/shared_preferences.dart';

class RecommandationsHistoryService {
  static const String _historyKey = 'viewed_activities';

  Future<void> addViewedActivity(String activityId) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await _getHistory(prefs);
    
    history.add({
      'activityId': activityId,
      'timestamp': DateTime.now().toIso8601String()
    });
    
    await prefs.setStringList(_historyKey, 
      history.map((h) => '${h['activityId']}|${h['timestamp']}').toList());
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return await _getHistory(prefs);
  }

  Future<List<String>> getRecentActivityTypes() async {
    final history = await getHistory();
    final typeCounts = <String, int>{};
    
    for (final entry in history) {
      final type = (entry['activityId'] as String).split('_')[0];
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }

    final sortedTypes = typeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedTypes
      .take(3)
      .map((e) => e.key)
      .toList();
  }

  Future<List<Map<String, dynamic>>> _getHistory(SharedPreferences prefs) async {
    final data = prefs.getStringList(_historyKey) ?? [];
    return data.map((entry) {
      final parts = entry.split('|');
      return {
        'activityId': parts[0],
        'timestamp': parts[1]
      };
    }).toList();
  }
}
