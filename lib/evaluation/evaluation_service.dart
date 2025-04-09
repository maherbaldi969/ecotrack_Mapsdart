import 'dart:convert';
import 'package:http/http.dart' as http;
import 'evaluation.dart';

class EvaluationService {
  static const String apiUrl = "https://votre-api.com/evaluations";

  static Future<bool> submitEvaluation(Evaluation evaluation) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(evaluation.toMap()),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception("Erreur serveur: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erreur de connexion: ${e.toString()}");
    }
  } 

  static Future<List<Evaluation>> getGuideEvaluations(String guideId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl?guideId=$guideId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Evaluation.fromMap(e)).toList();
      } else {
        throw Exception("Erreur serveur: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erreur de connexion: ${e.toString()}");
    }
  }
}