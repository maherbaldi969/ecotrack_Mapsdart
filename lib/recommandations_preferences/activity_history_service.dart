import 'package:shared_preferences/shared_preferences.dart';

class ActivityHistoryService {
  static const String _historyKey = 'activity_history';

  Future<void> recordActivity(String activityId, String activityType) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await _getHistory(prefs);
    
    // Format: type|id|timestamp
    final entry = '$activityType|$activityId|${DateTime.now().millisecondsSinceEpoch}';
    final newHistory = [entry, ...history.take(99)]; // Keep last 100 entries
    
    await prefs.setStringList(_historyKey, newHistory);
  }

  Future<List<String>> getTopActivityTypes({int limit = 3}) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await _getHistory(prefs);
    final typeCounts = <String, int>{};

    for (final entry in history) {
      final type = entry.split('|').first;
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }

    final sortedTypes = typeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedTypes
      .take(limit)
      .map((entry) => entry.key)
      .toList();
  }

  Future<List<Map<String, dynamic>>> getRecentlyViewed({int limit = 5}) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await _getHistory(prefs);
    
    return history.take(limit).map((entry) {
      final parts = entry.split('|');
      return {
        'type': parts[0],
        'id': parts[1],
        'timestamp': int.parse(parts[2])
      };
    }).toList();
  }

  Future<List<String>> getRecentActivityIds() async {
    final prefs = await SharedPreferences.getInstance();
    final history = await _getHistory(prefs);
    
    return history
      .map((entry) => entry.split('|')[1]) // Extract activityId
      .toList();
  }

  Future<List<String>> _getHistory(SharedPreferences prefs) async {
    return prefs.getStringList(_historyKey) ?? [];
  }
}
