import 'package:flutter/material.dart';
import '../models/tour.dart';
import '../navigationetsuivi/Maps.dart';

class DetailSliverDelegate extends SliverPersistentHeaderDelegate {
  final Tour Progs;
  final double expandedHeight;
  final double roundedContainerHeight;

  DetailSliverDelegate({
    required this.Progs,
    required this.expandedHeight,
    required this.roundedContainerHeight,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      children: [
        Hero(
          tag: Progs.title,
          child: Image.asset(
            // Use first image from Tour or a placeholder
            Progs.postContent.isNotEmpty ? Progs.postContent : 'assets/images/prog1.jpg',
            width: MediaQuery.of(context).size.width,
            height: expandedHeight,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[200],
              child: Icon(Icons.image_not_supported, color: Color(0xFF80C000)),
            ),
          ),
        ),
        // Back Button (Left)
        Positioned(
          top: MediaQuery.of(context).padding.top,
          left: 25,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_outlined,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // Place Icon (Right)
        Positioned(
          top: MediaQuery.of(context).padding.top,
          right: 25, // ✅ Corrected positioning to the right
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapsPage()),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.place,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // Rounded Bottom Section
        Positioned(
          top: expandedHeight - roundedContainerHeight - shrinkOffset,
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: roundedContainerHeight,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Container(
              alignment: Alignment.center,
              width: 60,
              height: 5,
              color: const Color(0xFF80C000),
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => 0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
