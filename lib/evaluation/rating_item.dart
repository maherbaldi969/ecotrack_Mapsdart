import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RatingItem extends StatefulWidget {
  final String label;
  final List<String> ratingDescriptions;
  final ValueChanged<double> onRatingChanged;
  final Color color;
  final double initialRating;

  const RatingItem({
    super.key,
    required this.label,
    required this.ratingDescriptions,
    required this.onRatingChanged,
    this.color = Colors.amber,
    this.initialRating = 0,
  });

  @override
  State<RatingItem> createState() => _RatingItemState();
}

class _RatingItemState extends State<RatingItem> {
  late double _rating;
  double _hoverRating = 0;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label principal
        Text(
          widget.label,
          style: GoogleFonts.merriweather(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),

        // Étoiles de notation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final starValue = index + 1.0;
            return MouseRegion(
              onEnter: (_) => setState(() => _hoverRating = starValue),
              onExit: (_) => setState(() => _hoverRating = 0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = starValue;
                    widget.onRatingChanged(_rating);
                  });
                },
                child: Column(
                  children: [
                    // Icône étoile
                    Icon(
                      index < _rating || (_hoverRating > 0 && index < _hoverRating)
                          ? Icons.star
                          : Icons.star_border,
                      color: widget.color,
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    // Description de la note
                    if (widget.ratingDescriptions.length > index)
                      SizedBox(
                        width: 60,
                        child: Text(
                          widget.ratingDescriptions[index],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.merriweather(
                            fontSize: 10,
                            color: _rating == starValue || _hoverRating == starValue
                                ? Colors.black
                                : Colors.grey,
                            fontWeight: _rating == starValue
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),

        // Affiche la description complète au survol
        if (_hoverRating > 0 && widget.ratingDescriptions.length >= _hoverRating)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.ratingDescriptions[_hoverRating.toInt() - 1],
              style: GoogleFonts.merriweather(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
            ),
          ),
      ],
    );
  }
}