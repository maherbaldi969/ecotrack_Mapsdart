import 'package:flutter/material.dart';
import '../models/tour.dart';

class GallerySection extends StatelessWidget {
  final Tour tour;
  const GallerySection(this.tour, {super.key});

  @override
  Widget build(BuildContext context) {
    final images = <String>[]; // TODO: Extract images from tour.postContent or other fields if available

    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => SizedBox(
          width: 250,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: images.isNotEmpty
                ? Image.asset(
                    images[index],
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.grey[300],
                    child: Center(child: Text('No images')),
                  ),
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemCount: images.length,
      ),
    );
  }
}
