import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tour.dart';
import 'guideDetails.dart';

class HeaderSection extends StatelessWidget {
  final Tour tour;
  const HeaderSection(this.tour, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card(
        color: Colors.white, // White Background
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              // Title and Place
              Row(
                children: [
                  Icon(Icons.location_on, color: Color(0xFF80C000)), // Green Color
                  const SizedBox(width: 5),
                  Text(
                    tour.locationPoint ?? '',
                    style: GoogleFonts.merriweather(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black, // Black Text
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                tour.title ?? '',
                style: GoogleFonts.merriweather(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Black Text
                ),
              ),
              const SizedBox(height: 10),

              // Distance and Rating Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.directions_walk, size: 18, color: Color(0xFF80C000)), // Green Icon
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '\${tour.duration ?? ''} km à la ville',
                          style: GoogleFonts.merriweather(
                            fontSize: 14,
                            color: Colors.black, // Black Text
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: Color(0xFF80C000), size: 18), // Green Star
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '0 Reviews',
                          style: GoogleFonts.merriweather(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black, // Black Text
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Buttons Row
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
                    icon: Icon(Icons.group, color: Colors.white),
                    label: Text('Voir guides', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF80C000),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Téléchargement de la carte en cours...')),
                      );
                      // Actual download logic to be implemented in details.dart
                    },
                    icon: Icon(Icons.download, color: Colors.white),
                    label: Text('Télécharger la carte', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF80C000),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
