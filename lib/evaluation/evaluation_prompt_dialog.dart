import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EvaluationPromptDialog extends StatelessWidget {
  final String visiteId;
  final String guideId;
  final String userId;
  final String? guideName;
  final String? visitDate;

  const EvaluationPromptDialog({
    super.key,
    required this.visiteId,
    required this.guideId,
    required this.userId,
    this.guideName,
    this.visitDate,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_rate_rounded,
              size: 48,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            Text(
              "Évaluez votre expérience",
              style: GoogleFonts.merriweather(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (guideName != null)
              Text(
                "avec $guideName",
                style: GoogleFonts.merriweather(
                  fontSize: 16,
                ),
              ),
            if (visitDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "Visite du $visitDate",
                  style: GoogleFonts.merriweather(
                    color: Colors.grey,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey),
                    ),
                    child: Text(
                      "PLUS TARD",
                      style: GoogleFonts.merriweather(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/evaluation',
                        arguments: {
                          'visiteId': visiteId,
                          'guideId': guideId,
                          'userId': userId,
                          'guideName': guideName,
                          'visitDate': visitDate,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF80C000),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      "ÉVALUER",
                      style: GoogleFonts.merriweather(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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