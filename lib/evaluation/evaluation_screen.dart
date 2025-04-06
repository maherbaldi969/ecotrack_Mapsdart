import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'evaluation.dart';
import 'evaluation_service.dart';
import 'evaluation_success.dart';
import 'notification_service.dart';
import 'rating_item.dart';

class EvaluationScreen extends StatefulWidget {
  final String visiteId;
  final String guideId;
  final String userId;
  final String? guideName;
  final String? visiteDate;

  const EvaluationScreen({
    super.key,
    required this.visiteId,
    required this.guideId,
    required this.userId,
    this.guideName,
    this.visiteDate,
  });

  static Future<void> navigateFromNotification(
      BuildContext context, {
        required String visiteId,
        required String guideId,
        required String userId,
      }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EvaluationScreen(
          visiteId: visiteId,
          guideId: guideId,
          userId: userId,
        ),
      ),
    );
  }

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  double _noteAccompagnement = 0;
  double _noteConnaissance = 0;
  double _noteAccueil = 0;
  double _notePonctualite = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  final int _maxCommentLength = 500;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitEvaluation() async {
    if (_noteAccompagnement == 0 ||
        _noteConnaissance == 0 ||
        _noteAccueil == 0 ||
        _notePonctualite == 0) {
      _showErrorSnackBar("Veuillez noter tous les critères");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final evaluation = Evaluation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        visiteId: widget.visiteId,
        userId: widget.userId,
        guideId: widget.guideId,
        noteAccompagnement: _noteAccompagnement,
        noteConnaissance: _noteConnaissance,
        noteAccueil: _noteAccueil,
        notePonctualite: _notePonctualite,
        commentaire: _commentController.text,
        date: DateTime.now(),
      );

      final success = await EvaluationService.submitEvaluation(evaluation);

      if (success && mounted) {
        await NotificationService.showInstantNotification(
          title: "Merci pour votre évaluation !",
          body: "Votre feedback est précieux pour nous",
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const EvaluationSuccessScreen(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("Erreur: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Évaluation du guide${widget.guideName != null ? ' ${widget.guideName}' : ''}",
          style: GoogleFonts.merriweather(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (widget.visiteDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "Visite du ${widget.visiteDate!}",
              style: GoogleFonts.merriweather(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      children: [
        RatingItem(
          label: "Qualité de l'accompagnement",
          ratingDescriptions: const [
            "1 - Guide absent",
            "2 - Peu impliqué",
            "3 - Correct",
            "4 - Bon accompagnement",
            "5 - Exceptionnel"
          ],
          onRatingChanged: (rating) => setState(() => _noteAccompagnement = rating),
          color: const Color(0xFF80C000),
        ),
        const SizedBox(height: 20),
        RatingItem(
          label: "Connaissance des lieux",
          ratingDescriptions: const [
            "1 - Connaissances limitées",
            "2 - Quelques erreurs",
            "3 - Correctes",
            "4 - Bonnes explications",
            "5 - Expertise exceptionnelle"
          ],
          onRatingChanged: (rating) => setState(() => _noteConnaissance = rating),
          color: const Color(0xFF80C000),
        ),
        const SizedBox(height: 20),
        RatingItem(
          label: "Accueil et sympathie",
          ratingDescriptions: const [
            "1 - Désagréable",
            "2 - Peu sympathique",
            "3 - Neutre",
            "4 - Agréable",
            "5 - Très chaleureux"
          ],
          onRatingChanged: (rating) => setState(() => _noteAccueil = rating),
          color: const Color(0xFF80C000),
        ),
        const SizedBox(height: 20),
        RatingItem(
          label: "Ponctualité",
          ratingDescriptions: const [
            "1 - Très en retard",
            "2 - Retard notable",
            "3 - À l'heure",
            "4 - En avance",
            "5 - Parfaitement ponctuel"
          ],
          onRatingChanged: (rating) => setState(() => _notePonctualite = rating),
          color: const Color(0xFF80C000),
        ),
      ],
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Votre commentaire (facultatif)",
              style: GoogleFonts.merriweather(),
            ),
            Text(
              "${_commentController.text.length}/$_maxCommentLength",
              style: GoogleFonts.merriweather(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _commentController,
          maxLines: 5,
          maxLength: _maxCommentLength,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: "Décrivez votre expérience...",
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onChanged: (text) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitEvaluation,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF80C000),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 3,
            ),
            child: AnimatedOpacity(
              opacity: _isSubmitting ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: Text(
                "SOUMETTRE L'ÉVALUATION",
                style: GoogleFonts.merriweather(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (_isSubmitting)
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildEvaluationPreview() {
    final hasRatings = _noteAccompagnement > 0 ||
        _noteConnaissance > 0 ||
        _noteAccueil > 0 ||
        _notePonctualite > 0;

    if (!hasRatings && _commentController.text.isEmpty) return const SizedBox();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Résumé de votre évaluation",
            style: GoogleFonts.merriweather(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          if (_noteAccompagnement > 0)
            _buildRatingPreview("Accompagnement", _noteAccompagnement),
          if (_noteConnaissance > 0)
            _buildRatingPreview("Connaissance", _noteConnaissance),
          if (_noteAccueil > 0)
            _buildRatingPreview("Accueil", _noteAccueil),
          if (_notePonctualite > 0)
            _buildRatingPreview("Ponctualité", _notePonctualite),
          if (_commentController.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              "Commentaire :",
              style: GoogleFonts.merriweather(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _commentController.text,
              style: GoogleFonts.merriweather(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingPreview(String label, double rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label : ", style: GoogleFonts.merriweather()),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                size: 18,
                color: const Color(0xFF80C000),
              );
            }),
          ),
          const SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: GoogleFonts.merriweather(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Évaluer votre guide",
          style: GoogleFonts.merriweather(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFF80C000),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Text(
              "Comment s'est passée votre expérience ?",
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildRatingSection(),
            const SizedBox(height: 20),
            _buildEvaluationPreview(),
            const SizedBox(height: 20),
            _buildCommentSection(),
            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }
}