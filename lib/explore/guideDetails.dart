import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/progModels.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class GuideReviewsPage extends StatefulWidget {
  final progModels progs;
  const GuideReviewsPage(this.progs, {super.key});

  @override
  State<GuideReviewsPage> createState() => _GuideReviewsPageState();
}

class _GuideReviewsPageState extends State<GuideReviewsPage> {
  bool _isMounted = true;

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> downloadReviews() async {
    try {
      // For demonstration, create a simple CSV string of reviews
      String csv = 'Voyageur,Date,Note,Commentaire\n';
      for (int i = 0; i < 5; i++) {
        csv += 'Voyageur \${i + 1},2024-10-01,4,Super guide ! Très professionnel et connaît bien la région.\n';
      }
      final dir = await getApplicationDocumentsDirectory();
      final file = File('\${dir.path}/reviews_\${widget.progs.title}.csv');
      await file.writeAsString(csv);
      if (!_isMounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Avis téléchargés: \${file.path}')),
      );
    } catch (e) {
      if (!_isMounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du téléchargement des avis')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF80C000),
        foregroundColor: Colors.white,
        title: Text('Avis sur le Guide',
            style: GoogleFonts.merriweather(color: Colors.white)),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GuideInfoSection(widget.progs),
            const SizedBox(height: 10),
            const ReviewFilters(),
            const Expanded(child: ReviewsList()),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF80C000),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: downloadReviews,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.download, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Télécharger les avis',
                      style: GoogleFonts.merriweather(fontSize: 16, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder widget definitions for missing widgets

class GuideInfoSection extends StatelessWidget {
  final progModels progs;
  const GuideInfoSection(this.progs, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text('Guide Info: \${progs.title}', style: const TextStyle(fontSize: 18));
  }
}

class ReviewFilters extends StatelessWidget {
  const ReviewFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('Review Filters Placeholder', style: const TextStyle(fontSize: 16));
  }
}

class ReviewsList extends StatelessWidget {
  const ReviewsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Reviews List Placeholder'));
  }
}
