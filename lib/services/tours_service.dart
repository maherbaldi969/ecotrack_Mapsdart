import 'dart:convert';
import 'package:http/http.dart' as http;

class ToursService {
  final String baseUrl = 'http://192.168.112.51:3000';

  Future<List<dynamic>> getAllTours() async {
    final response = await http.get(Uri.parse('\$baseUrl/tours/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load tours');
    }
  }

  Future<Map<String, dynamic>> getTourDetails(String id) async {
    final response = await http.get(Uri.parse('\$baseUrl/tours/\$id'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load tour details');
    }
  }

  Future<List<dynamic>> getTourGuides(String id) async {
    final response = await http.get(Uri.parse('\$baseUrl/tours/\$id/guides'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load tour guides');
    }
  }

  Future<List<dynamic>> filterTours(
      {String? langue, int? duree, int? prix}) async {
    final queryParameters = <String, String>{};
    if (langue != null) queryParameters['langue'] = langue;
    if (duree != null) queryParameters['duree'] = duree.toString();
    if (prix != null) queryParameters['prix'] = prix.toString();

    final uri = Uri.parse('\$baseUrl/tours/filter')
        .replace(queryParameters: queryParameters);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to filter tours');
    }
  }

  Future<List<int>> downloadTourMap(String id) async {
    final response = await http.get(Uri.parse('\$baseUrl/tours/\$id/map'));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to download tour map');
    }
  }
}
