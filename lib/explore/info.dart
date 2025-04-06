import 'package:flutter/material.dart';
import '../models/progModels.dart';
import 'DescriptionSection.dart';
import 'HeaderSection.dart';
import 'ReviewSection.dart';
import 'gallery.dart';

class ProgInfo extends StatelessWidget {
  final progModels Progs;

  const ProgInfo(this.Progs, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Suppression du mode sombre basé sur ThemeProvider
      child: Column(
        children: [
          HeaderSection(Progs),
          GallerySection(Progs),
          DescriptionSection(Progs),
          ReviewSection(Progs),
        ],
      ),
    );
  }
}
