import 'package:shared_preferences/shared_preferences.dart';

class RecommendationHistory {
  static const String _historyKey = 'recommendation_history';

  Future<void> recordActivityView(String activityId, String activityType) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await _getHistory(prefs);
    
    final entry = '$activityType|$activityId|${DateTime.now().millisecondsSinceEpoch}';
    final newHistory = [entry, ...history.take(99)];
    
    await prefs.setStringList(_historyKey, newHistory);
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = await _getHistory(prefs);
    
    return history.map((entry) {
      final parts = entry.split('|');
      return {
        'type': parts[0],
        'id': parts[1],
        'timestamp': int.parse(parts[2])
      };
    }).toList();
  }

  Future<List<String>> getPreferredActivityTypes({int limit = 3}) async {
    final history = await getHistory();
    final typeCounts = <String, int>{};
    
    for (final entry in history) {
      final type = entry['type'] as String;
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }

    final sortedEntries = typeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedEntries
      .take(limit)
      .map((e) => e.key)
      .toList();
  }

  Future<List<String>> _getHistory(SharedPreferences prefs) async {
    return prefs.getStringList(_historyKey) ?? [];
  }
}
