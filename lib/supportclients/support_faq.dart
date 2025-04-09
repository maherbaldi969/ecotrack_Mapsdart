import 'package:flutter/material.dart';
import 'support_style.dart';

class SupportFAQ extends StatelessWidget {
  const SupportFAQ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQ & Guides', style: merriweatherBold),
        backgroundColor: vertPrimaire,
        foregroundColor: blanc,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'FAQ'),
                Tab(text: 'Guides'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Onglet FAQ existant
                  ListView(
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
                  
                  // Nouvel onglet Guides
                  ListView(
                    children: [
                      _GuideItem(
                        title: "Utiliser l'application",
                        icon: Icons.phone_iphone,
                        steps: [
                          "Télécharger l'application",
                          "Créer un compte",
                          "Explorer les fonctionnalités"
                        ],
                      ),
                      _GuideItem(
                        title: "Faire une réservation",
                        icon: Icons.calendar_today,
                        steps: [
                          "Choisir une activité",
                          "Sélectionner un guide",
                          "Confirmer la réservation"
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

class _GuideItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> steps;

  const _GuideItem({
    required this.title,
    required this.icon,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(icon, color: vertPrimaire),
      title: Text(title, style: merriweatherBold),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: steps.map((step) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(child: Text(step, style: merriweatherNormal)),
                  ],
                ),
              )
            ).toList(),
          ),
        ),
      ],
    );
  }
}
