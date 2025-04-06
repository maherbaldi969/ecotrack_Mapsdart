import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'select_activities.dart';
import 'saved_programs.dart';
import 'preferences_page.dart';

class PersonalisationHome extends StatelessWidget {
  const PersonalisationHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Personnalisation de Programme",
          style: GoogleFonts.merriweather(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF80C000),
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: const Color(0xFF80C000),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF5F5F5)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTravelIcon(),
                const SizedBox(height: 32),
                _buildCreateProgramButton(context),
                const SizedBox(height: 16),
                _buildViewProgramsButton(context),
                const SizedBox(height: 32),
                _buildDescriptionText(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickStartGuide(context),
        backgroundColor: const Color(0xFF80C000),
        child: const Icon(Icons.help_outline),
        tooltip: 'Guide rapide',
      ),
    );
  }

  Widget _buildTravelIcon() {
    return const Icon(
      Icons.travel_explore,
      size: 120,
      color: Color(0xFF80C000),
    );
  }

  Widget _buildCreateProgramButton(BuildContext context) {
    return _CustomButton(
      icon: Icons.add_circle_outline,
      text: "Créer un nouveau programme",
      color: const Color(0xFF80C000),
      onPressed: () async {
        final prefs = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PreferencesPage()),
        );

        if (prefs != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelectActivitiesPage([], preferences: prefs),
            ),
          );
        }
      },
    );
  }

  Widget _buildViewProgramsButton(BuildContext context) {
    return _CustomButton(
      icon: Icons.bookmark_border,
      text: "Voir mes programmes enregistrés",
      color: Colors.black,
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SavedProgramsPage()),
      ),
    );
  }

  Widget _buildDescriptionText() {
    return Column(
      children: [
        Text(
          "Créez des itinéraires personnalisés",
          textAlign: TextAlign.center,
          style: GoogleFonts.merriweather(
            fontSize: 16,
            color: Colors.black,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Selon vos envies, préférences et contraintes",
          textAlign: TextAlign.center,
          style: GoogleFonts.merriweather(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _showQuickStartGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Guide rapide",
                style: GoogleFonts.merriweather(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildGuideStep(
                icon: Icons.add_circle_outline,
                title: "Créer un programme",
                description: "Définissez vos préférences et sélectionnez vos activités",
              ),
              _buildGuideStep(
                icon: Icons.bookmark_border,
                title: "Programmes enregistrés",
                description: "Retrouvez tous vos programmes sauvegardés",
              ),
              _buildGuideStep(
                icon: Icons.filter_alt,
                title: "Filtres avancés",
                description: "Filtrez par durée, budget et catégories",
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("J'ai compris"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF80C000),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuideStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF80C000)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.merriweather(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.merriweather(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _CustomButton({
    required this.icon,
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            text,
            style: GoogleFonts.merriweather(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Colors.black26,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
      ),
    );
  }
}