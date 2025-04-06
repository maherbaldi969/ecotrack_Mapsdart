import 'package:flutter/material.dart';

void main() {
  runApp(OfflineMapsApp());
}

class OfflineMapsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OfflineMapsPage(),
    );
  }
}

class OfflineMapsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enregistrement des cartes'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enregistrement des cartes...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Enregistrement des cartes et itinéraires pour une utilisation hors réseau',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Vous avez déjà planifié en ligne votre prochaine sortie mais vous n\'êtes pas sûr de la couverture internet dans la zone concernée ? Pas de problème !\n'
                  'Avec l\'application mobile, vous pouvez télécharger facilement à l\'avance des itinéraires et des cartes puis accéder à votre contenu à tout moment sans connexion internet.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Text(
              'Réduire le texte',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
