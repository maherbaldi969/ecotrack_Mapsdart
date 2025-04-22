import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tour.dart';
import '../services/tours_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class GuideReviewsPage extends StatefulWidget {
  final Tour tour;
  const GuideReviewsPage(this.tour, {super.key});

  @override
  State<GuideReviewsPage> createState() => _GuideReviewsPageState();
}

class _GuideReviewsPageState extends State<GuideReviewsPage> {
  bool _isMounted = true;
  bool isLoading = true;
  String? errorMessage;
  List<dynamic> guides = [];

  final ToursService toursService = ToursService();

  @override
  void initState() {
    super.initState();
    fetchGuides();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> fetchGuides() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final fetchedGuides = await toursService.getTourGuides(widget.tour.id.toString());
      if (!_isMounted) return;
      setState(() {
        guides = fetchedGuides;
        isLoading = false;
      });
    } catch (e) {
      if (!_isMounted) return;
      setState(() {
        errorMessage = "Erreur lors du chargement des guides.";
        isLoading = false;
      });
    }
  } 

  Future<void> downloadReviews() async {
    try {
      String csv = 'Voyageur,Date,Note,Commentaire\n';
      for (int i = 0; i < 5; i++) {
        csv += 'Voyageur \${i + 1},2024-10-01,4,Super guide ! Très professionnel et connaît bien la région.\n';
      }
      final dir = await getApplicationDocumentsDirectory();
      final file = File('\${dir.path}/reviews_\${widget.tour.title}.csv');
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
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF80C000),
          foregroundColor: Colors.white,
          title: Text('Guides associés',
              style: GoogleFonts.merriweather(color: Colors.white)),
          centerTitle: false,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF80C000),
          foregroundColor: Colors.white,
          title: Text('Guides associés',
              style: GoogleFonts.merriweather(color: Colors.white)),
          centerTitle: false,
        ),
        body: Center(
          child: Text(
            errorMessage!,
            style: GoogleFonts.merriweather(color: Color(0xFF80C000)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF80C000),
        foregroundColor: Colors.white,
        title: Text('Guides associés',
            style: GoogleFonts.merriweather(color: Colors.white)),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: guides.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final guide = guides[index];
                  return ListTile(
                    title: Text(
                      guide['display_name'] ?? 'Nom inconnu',
                      style: GoogleFonts.merriweather(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Langue(s) parlée(s): ${guide['meta']?['langue'] ?? 'N/A'}',
                            style: GoogleFonts.poppins()),
                        Text('Expérience: ${guide['meta']?['experience'] ?? 'N/A'} ans',
                            style: GoogleFonts.poppins()),
                      ],
                    ),
                    onTap: () {
                      // Optional: Implement onTap to show guide details or reviews
                    },
                  );
                },
              ),
            ),
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

