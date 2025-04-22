import 'package:flutter/material.dart';
import '../models/tour.dart';
import 'DescriptionSection.dart';
import 'HeaderSection.dart';
import 'ReviewSection.dart';
import 'gallery.dart';

class ProgInfo extends StatelessWidget {
  final Tour tour;

  const ProgInfo(this.tour, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Suppression du mode sombre basé sur ThemeProvider
      child: Column(
        children: [
          HeaderSection(tour),
          GallerySection(tour),
          DescriptionSection(tour),
          ReviewSection(tour),
        ],
      ),
    );
  }
}
