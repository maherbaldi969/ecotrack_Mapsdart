import 'package:flutter/material.dart';
import 'support_style.dart';
import 'support_chat.dart';
import 'support_appel.dart';
import 'support_faq.dart';
import 'support_formulaire.dart';
import 'support_redirect.dart';
import 'support_history.dart';

class SupportHome extends StatelessWidget {
  const SupportHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support Client', style: merriweatherBold),
        backgroundColor: vertPrimaire,
        foregroundColor: blanc,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _SupportOption(
            icon: Icons.chat,
            title: 'Chat en direct',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SupportChat()),
            ),
          ),
          _SupportOption(
            icon: Icons.phone,
            title: 'Appel téléphonique',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SupportAppel()),
            ),
          ),
          _SupportOption(
            icon: Icons.help_outline,
            title: 'FAQ & Guides',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SupportFAQ()),
            ),
          ),
          _SupportOption(
            icon: Icons.assignment,
            title: 'Formulaire',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SupportFormulaire()),
            ),
          ),
          _SupportOption(
            icon: Icons.history,
            title: 'Historique',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SupportHistory()),
            ),
          ),
          _SupportOption(
            icon: Icons.place,
            title: 'Partenaires locaux',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SupportRedirect()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SupportOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: vertPrimaire),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: merriweatherBold.copyWith(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
