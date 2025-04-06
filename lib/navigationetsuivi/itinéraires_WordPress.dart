import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DownloadedItinerariesPage extends StatefulWidget {
  @override
  _DownloadedItinerariesPageState createState() => _DownloadedItinerariesPageState();
}

class _DownloadedItinerariesPageState extends State<DownloadedItinerariesPage> {
  List<Map<String, dynamic>> itineraries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDownloadedItineraries();
  }

  Future<void> fetchDownloadedItineraries() async {
    final url = Uri.parse("https://example.com/wp-json/ecotrack/v1/downloaded-itineraries"); // Remplace par ton URL

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          itineraries = data.map((e) => Map<String, dynamic>.from(e)).toList();
          isLoading = false;
        });
      } else {
        showError("Impossible de récupérer les itinéraires.");
      }
    } catch (e) {
      showError("Erreur de connexion au serveur.");
    }
  }

  void showError(String message) {
    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEFF3), // Fond de la page
      appBar: AppBar(
        backgroundColor: const Color(0xFF80C000), // Couleur de l'AppBar
        title: const Text(
          'elguid.com',
          style: TextStyle(
            color: Colors.white, // Couleur du texte de l'AppBar
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF80C000)))
          : itineraries.isEmpty
          ? Center(
        child: Text(
          "Aucun itinéraire téléchargé.",
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: itineraries.length,
        itemBuilder: (context, index) {
          var itinerary = itineraries[index];
          return _buildItineraryCard(itinerary);
        },
      ),
    );
  }

  Widget _buildItineraryCard(Map<String, dynamic> itinerary) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 10),
      color: Colors.white,
      elevation: 3,
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            itinerary["image_url"] ?? "https://example.com/default-image.jpg",
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          itinerary["title"],
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Distance: ${itinerary["distance"]} km\nDurée: ${itinerary["duration"]}",
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
        onTap: () {
          _showItineraryDetails(context, itinerary);
        },
      ),
    );
  }

  void _showItineraryDetails(BuildContext context, Map<String, dynamic> itinerary) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            itinerary["title"],
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(itinerary["image_url"], width: 300),
              ),
              SizedBox(height: 8),
              Text(
                itinerary["description"],
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              ),
              SizedBox(height: 8),
              Text("Distance: ${itinerary["distance"]} km",
                  style: GoogleFonts.poppins(fontSize: 14)),
              Text("Durée: ${itinerary["duration"]}",
                  style: GoogleFonts.poppins(fontSize: 14)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Fermer",
                  style: GoogleFonts.poppins(color: Color(0xFF80C000))),
            ),
          ],
        );
      },
    );
  }
}
