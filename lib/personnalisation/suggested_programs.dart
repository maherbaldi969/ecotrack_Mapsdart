import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'activity.dart';
import 'program.dart';
import 'finalize_program.dart';

class SuggestedProgramsPage extends StatelessWidget {
  final List<Activity> selectedActivities;

  const SuggestedProgramsPage(this.selectedActivities, {super.key});

  @override
  Widget build(BuildContext context) {
    List<Program> suggestedPrograms = [
      Program(
        name: "Mon programme personnalisé",
        activities: selectedActivities,
      ),
      if (selectedActivities.any((a) => a.category == "Sport"))
        Program(
          name: "Aventure active",
          activities: selectedActivities.where((a) => a.category == "Sport").toList(),
        ),
      if (selectedActivities.any((a) => a.category == "Culture"))
        Program(
          name: "Découverte culturelle",
          activities: selectedActivities.where((a) => a.category == "Culture").toList(),
        ),
    ].where((p) => p.activities.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Programmes suggérés",
          style: GoogleFonts.merriweather(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF80C000),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: suggestedPrograms.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: suggestedPrograms.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final program = suggestedPrograms[index];
          return _buildProgramCard(program, context);
        },
      ),
    );
  }

  Widget _buildProgramCard(Program program, BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToFinalize(context, program),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    program.name,
                    style: GoogleFonts.merriweather(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF80C000).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${program.totalDuration()}h',
                      style: GoogleFonts.merriweather(
                        color: const Color(0xFF80C000),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...program.activities.map((activity) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      activity.icon,
                      size: 20,
                      color: const Color(0xFF80C000),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        activity.name,
                        style: GoogleFonts.merriweather(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Text(
                      '${activity.duration}h',
                      style: GoogleFonts.merriweather(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            "Aucune suggestion disponible",
            style: GoogleFonts.merriweather(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Sélectionnez plus d'activités pour obtenir des suggestions",
            style: GoogleFonts.merriweather(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToFinalize(BuildContext context, Program program) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinalizeProgramPage(program),
      ),
    );
  }
}