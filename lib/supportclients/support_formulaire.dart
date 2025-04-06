import 'package:flutter/material.dart';
import 'support_style.dart';

class SupportFormulaire extends StatelessWidget {
  const SupportFormulaire({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulaire de contact', style: merriweatherBold),
        backgroundColor: vertPrimaire,
        foregroundColor: blanc,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Nom",
                labelStyle: merriweatherNormal,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: merriweatherNormal,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Message",
                labelStyle: merriweatherNormal,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: boutonVert,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Message envoyé !', style: merriweatherNormal)),
                );
              },
              child: const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }
}