import 'package:flutter/material.dart';
import 'support_style.dart';

class SupportAppel extends StatelessWidget {
  const SupportAppel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appeler le support', style: merriweatherBold),
        backgroundColor: vertPrimaire,
        foregroundColor: blanc,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone, size: 60, color: vertPrimaire),
            const SizedBox(height: 20),
            Text('Appuyez pour appeler le support :', style: merriweatherNormal),
            const SizedBox(height: 10),
            Text('+216 71 789 900', style: merriweatherBold.copyWith(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: boutonVert,
              onPressed: () {}, // Ici, intégrer un package comme `url_launcher` pour les appels
              child: const Text('Appeler maintenant'),
            ),
          ],
        ),
      ),
    );
  }
}