import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/favorites_manager.dart';
import 'itinerary_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoritesManager = Provider.of<FavoritesManager>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFEEEFF3), // Fond de la page
      appBar: AppBar(
        backgroundColor: const Color(0xFF80C000), // Couleur de l'AppBar
        title: Text(
          'elguid.com',
          style: GoogleFonts.poppins(
            color: Colors.white, // Couleur du texte de l'AppBar
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: favoritesManager.favoriteItineraries.isEmpty
          ? Center(
        child: Text(
          'Aucun itinéraire favori.',
          style: GoogleFonts.poppins(
            color: isDarkMode ? Colors.white : const Color(0xFF000000), // Texte blanc en mode sombre
            fontSize: 18,
          ),
        ),
      )
          : ListView.builder(
        itemCount: favoritesManager.favoriteItineraries.length,
        itemBuilder: (context, index) {
          final itinerary = favoritesManager.favoriteItineraries[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            color: isDarkMode ? const Color(0xFF333333) : Colors.white, // Couleur de fond de la carte
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                itinerary.name,
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white : const Color(0xFF000000), // Couleur du titre
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${itinerary.distance} km - ${itinerary.difficulty}',
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white70 : const Color(0xFF000000).withOpacity(0.6), // Couleur du sous-titre
                  fontSize: 16,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward, color: Color(0xFF80C000)), // Couleur de l'icône
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItineraryDetailScreen(itinerary: itinerary),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}