import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tour.dart';
import '../services/tours_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'guideDetails.dart';

class Details extends StatefulWidget {
  const Details({super.key, required this.Progs});
  final Tour Progs;

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  Tour? fullTour;
  bool isLoading = true;
  String? errorMessage;

  final ToursService toursService = ToursService();

  @override
  void initState() {
    super.initState();
    fetchFullTourDetails();
  }

  Future<void> fetchFullTourDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final tourMap =
          await toursService.getTourDetails(widget.Progs.id.toString());
      setState(() {
        fullTour = Tour.fromMap(tourMap['data'] ?? tourMap);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Erreur lors du chargement des détails du tour.";
        isLoading = false;
      });
    }
  }

  Future<void> downloadMap(BuildContext context) async {
    try {
      final bytes =
          await toursService.downloadTourMap(widget.Progs.id.toString());
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/tour_map_${widget.Progs.title}.pdf');
      await file.writeAsBytes(bytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Carte téléchargée: ${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du téléchargement de la carte')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF80C000),
          elevation: 0,
          title: Text(
            'Eco Track',
            style: GoogleFonts.merriweather(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF80C000),
          elevation: 0,
          title: Text(
            'Eco Track',
            style: GoogleFonts.merriweather(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Text(
            errorMessage!,
            style: GoogleFonts.merriweather(color: Color(0xFF80C000)),
          ),
        ),
      );
    }

    final tour = fullTour ?? widget.Progs;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF80C000),
        elevation: 0,
        title: Text(
          'Eco Track',
          style: GoogleFonts.merriweather(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tour.title,
              style: GoogleFonts.merriweather(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF80C000),
              ),
            ),
            SizedBox(height: 8),
            Text(
              tour.description,
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.place, color: Color(0xFF80C000)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tour.locationPoint,
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, color: Color(0xFF80C000)),
                SizedBox(width: 8),
                Text(
                  '${tour.duration} heures',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.attach_money, color: Color(0xFF80C000)),
                SizedBox(width: 8),
                Text(
                  tour.price,
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              tour.postTitle,
              style: GoogleFonts.merriweather(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              tour.postContent,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GuideReviewsPage(tour),
                      ),
                    );
                  },
                  icon: Icon(Icons.group),
                  label: Text('Voir guides'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF80C000),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => downloadMap(context),
                  icon: Icon(Icons.download),
                  label: Text('Télécharger la carte'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF80C000),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
