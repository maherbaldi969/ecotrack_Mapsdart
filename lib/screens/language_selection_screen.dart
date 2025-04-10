import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecotrack/services/language_service.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Blanc
      appBar: AppBar(
        title: Text(
          'Choisir la langue',
          style: GoogleFonts.merriweather(
            color: const Color(0xFF000000), // Noir
          ),
        ),
        backgroundColor: const Color(0xFF80C000), // Vert #80c000
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF000000)), // Noir
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Sélectionnez votre langue préférée',
                style: GoogleFonts.merriweather(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF000000), // Noir
                ),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: ListView.builder(
                    itemCount: languageService.availableLanguages.length,
                    itemBuilder: (context, index) {
                      final languageCode = languageService
                          .availableLanguages.keys
                          .elementAt(index);
                      final languageName =
                          languageService.availableLanguages[languageCode]!;

                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            languageName,
                            style: GoogleFonts.merriweather(
                              fontSize: 16,
                              color: const Color(0xFF000000), // Noir
                            ),
                          ),
                          trailing:
                              languageService.currentLanguage == languageCode
                                  ? Icon(
                                      Icons.check_circle,
                                      color: const Color(0xFF80C000), // Vert
                                    )
                                  : null,
                          onTap: () {
                            languageService.changeLanguage(languageCode);
                            Navigator.pop(context);
                          },
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'EcoTrack © 2025',
                style: GoogleFonts.merriweather(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
