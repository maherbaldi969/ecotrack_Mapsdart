import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Fonction pour envoyer un itinéraire
Future<void> saveItinerary(BuildContext context, Map<String, dynamic> itineraryData) async {
  final url = Uri.parse("https://example.com/wp-json/ecotrack/v1/add-itinerary");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(itineraryData),
    );

    final result = jsonDecode(response.body);

    if (response.statusCode == 200 && result["success"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Itinéraire enregistré avec succès !")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${result["message"]}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Échec de connexion au serveur.")),
    );
  }
}
