import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class OfflineMapService {
  static Future<String?> downloadMapRegion(
      String regionName, String mapUrl) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/map_$regionName.zip');

      // Create the request
      final response = await HttpClient().getUrl(Uri.parse(mapUrl));
      final request = await response.close();

      // Write to file
      final bytes = await request.expand((b) => b).toList();
      await file.writeAsBytes(bytes);

      return file.path;
    } catch (e) {
      debugPrint('Download error: $e');
      return null;
    }
  }

  static Future<bool> isMapDownloaded(String regionName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/map_$regionName.zip');
      return await file.exists();
    } catch (e) {
      debugPrint('Map check error: $e');
      return false;
    }
  }

  static Future<void> deleteMapRegion(String regionName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/map_$regionName.zip');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  static Future<String?> getMapPath(String regionName) async {
    if (await isMapDownloaded(regionName)) {
      final dir = await getApplicationDocumentsDirectory();
      return '${dir.path}/map_$regionName.zip';
    }
    return null;
  }

  static Future<List<String>> getAvailableRegions() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = await Directory(dir.path)
          .list()
          .where((f) => f.path.endsWith('.zip'))
          .map((f) => f.path)
          .toList();
      return files;
    } catch (e) {
      debugPrint('Region list error: $e');
      return [];
    }
  }

  static Future<void> saveItinerary(Map<String, dynamic> itinerary) async {
    try {
      // Validate itinerary data
      if (itinerary.isEmpty) {
        throw Exception('Cannot save empty itinerary');
      }

      // Check for required fields
      if (!itinerary.containsKey('title') || !itinerary.containsKey('points')) {
        throw Exception('Itinerary must contain title and points');
      }

      final dir = await getApplicationDocumentsDirectory();
      final filename =
          'itinerary_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${dir.path}/$filename');

      // Convert to JSON and check size
      final jsonData = jsonEncode(itinerary);
      if (jsonData.length > 1024 * 1024) {
        // 1MB limit
        throw Exception('Itinerary too large to save');
      }

      // Write file
      await file.writeAsString(jsonData);

      debugPrint('Saved itinerary to $filename');
    } catch (e) {
      debugPrint('Save itinerary error: $e');
      throw Exception('Failed to save itinerary: ${e.toString()}');
    }
  }

  static Future<List<Map<String, dynamic>>> getSavedItineraries() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = (await Directory(dir.path).list().toList())
          .where((f) => f.path.endsWith('.json'))
          .where((f) => f.path.contains('itinerary_'))
          .toList();

      List<Map<String, dynamic>> itineraries = [];

      for (final file in files) {
        try {
          final content = await File(file.path).readAsString();
          final data = jsonDecode(content) as Map<String, dynamic>;
          itineraries.add(data);
        } catch (e) {
          debugPrint('Error reading itinerary file ${file.path}: $e');
        }
      }

      return itineraries;
    } catch (e) {
      debugPrint('Error getting saved itineraries: $e');
      return [];
    }
  }
}
