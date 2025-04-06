import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import pour SystemUiOverlayStyle
import 'package:google_fonts/google_fonts.dart';
import 'program.dart';
import 'storage_service.dart';

class SavedProgramsPage extends StatefulWidget {
  const SavedProgramsPage({super.key});

  @override
  State<SavedProgramsPage> createState() => _SavedProgramsPageState();
}

class _SavedProgramsPageState extends State<SavedProgramsPage> {
  List<Program> savedPrograms = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPrograms();
  }

  Future<void> _loadSavedPrograms() async {
    List<Program> programs = await StorageService.loadPrograms();
    setState(() {
      savedPrograms = programs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mes Programmes',
          style: GoogleFonts.merriweather(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF80C000),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: Colors.white,
      body: savedPrograms.isEmpty
          ? _buildEmptyState()
          : _buildProgramsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun programme enregistré',
            style: GoogleFonts.merriweather(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez par créer un nouveau programme',
            style: GoogleFonts.merriweather(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: savedPrograms.length,
      separatorBuilder: (context, index) => const Divider(height: 16),
      itemBuilder: (context, index) {
        final program = savedPrograms[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _navigateToProgramDetails(program),
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
                      _buildDurationChip(program.totalDuration()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (program.activities.isNotEmpty)
                    Text(
                      'Activités: ${program.activities.map((a) => a.name).join(', ')}',
                      style: GoogleFonts.merriweather(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDurationChip(int duration) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF80C000).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${duration}h',
        style: GoogleFonts.merriweather(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF80C000),
        ),
      ),
    );
  }

  void _navigateToProgramDetails(Program program) {
    // Implémentez la navigation vers les détails du programme
  }
}