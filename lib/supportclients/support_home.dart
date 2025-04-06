import 'package:flutter/material.dart';
import 'support_style.dart';
import 'support_chat.dart';
import 'support_formulaire.dart';
import 'support_faq.dart';
import 'support_appel.dart';

class SupportHome extends StatelessWidget {
  const SupportHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support Client', style: merriweatherBold.copyWith(fontSize: 24)),
        backgroundColor: vertPrimaire,
        foregroundColor: blanc,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [blanc.withOpacity(0.9), vertPrimaire.withOpacity(0.1)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            children: [
              Text(
                'Comment pouvons-nous vous aider ?',
                style: merriweatherBold.copyWith(fontSize: 20, color: noir),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _OptionSupport(
                      icon: Icons.chat_bubble_outlined,
                      titre: "Chat en direct",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SupportChat()),
                      ),
                    ),
                    _OptionSupport(
                      icon: Icons.email_outlined,
                      titre: "Formulaire de contact",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SupportFormulaire()),
                      ),
                    ),
                    _OptionSupport(
                      icon: Icons.phone_outlined,
                      titre: "Appeler le support",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SupportAppel()),
                      ),
                    ),
                    _OptionSupport(
                      icon: Icons.help_outline,
                      titre: "FAQ",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SupportFAQ()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionSupport extends StatelessWidget {
  final IconData icon;
  final String titre;
  final VoidCallback onTap;

  const _OptionSupport({
    required this.icon,
    required this.titre,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: blanc,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: vertPrimaire.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: Icon(icon, size: 32, color: vertPrimaire),
              ),
              const SizedBox(height: 16),
              Text(
                titre,
                style: merriweatherBold.copyWith(color: noir, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}