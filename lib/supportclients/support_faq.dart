import 'package:flutter/material.dart';
import 'support_style.dart';

class SupportFAQ extends StatelessWidget {
  const SupportFAQ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQ', style: merriweatherBold),
        backgroundColor: vertPrimaire,
        foregroundColor: blanc,
      ),
      body: ListView(
        children: const [
          _QuestionReponse(
            question: "Comment annuler une réservation ?",
            reponse: "Allez dans 'Mes réservations' et cliquez sur 'Annuler'.",
          ),
          _QuestionReponse(
            question: "Comment contacter un guide ?",
            reponse: "Utilisez le chat ou le formulaire de contact.",
          ),
        ],
      ),
    );
  }
}

class _QuestionReponse extends StatelessWidget {
  final String question;
  final String reponse;

  const _QuestionReponse({required this.question, required this.reponse});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(question, style: merriweatherBold),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(reponse, style: merriweatherNormal),
        ),
      ],
    );
  }
}