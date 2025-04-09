import 'package:flutter/material.dart';
import 'package:ecotrack/evaluation/evaluation_service.dart';
import 'package:ecotrack/evaluation/evaluation.dart';
import 'package:ecotrack/services/notifications_service.dart';

class GuideDashboardScreen extends StatefulWidget {
  final String guideId;

  const GuideDashboardScreen({super.key, required this.guideId});

  @override
  State<GuideDashboardScreen> createState() => _GuideDashboardScreenState();
}

class _GuideDashboardScreenState extends State<GuideDashboardScreen> {
  late Future<List<Evaluation>> _evaluations;
  double _averageRating = 0;
  int _totalEvaluations = 0;

  @override
  void initState() {
    super.initState();
    _loadEvaluations();
  }

  Future<void> _loadEvaluations() async {
    _evaluations = EvaluationService.getGuideEvaluations(widget.guideId);
    final evaluations = await _evaluations;
    
    if (evaluations.isNotEmpty) {
      final total = evaluations.fold(0.0, (sum, eval) => sum + 
        (eval.noteAccompagnement + eval.noteConnaissance + 
         eval.noteAccueil + eval.notePonctualite) / 4);
      
      setState(() {
        _averageRating = total / evaluations.length;
        _totalEvaluations = evaluations.length;
      });
    }
  }

  Widget _buildRatingIndicator(double rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          return Icon(
            index < rating.round() ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 30,
          );
        }),
      ],
    );
  }

  Widget _buildEvaluationCard(Evaluation evaluation) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              evaluation.commentaire.isNotEmpty 
                  ? evaluation.commentaire 
                  : "Aucun commentaire",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRatingIndicator(
                  (evaluation.noteAccompagnement + evaluation.noteConnaissance +
                   evaluation.noteAccueil + evaluation.notePonctualite) / 4
                ),
                Text(
                  "${evaluation.date.day}/${evaluation.date.month}/${evaluation.date.year}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Évaluations"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvaluations,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "Note Moyenne",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildRatingIndicator(_averageRating),
                    const SizedBox(height: 10),
                    Text(
                      "Basée sur $_totalEvaluations évaluation(s)",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Dernières Évaluations",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Evaluation>>(
                future: _evaluations,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Erreur: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Aucune évaluation trouvée"));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return _buildEvaluationCard(snapshot.data![index]);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
