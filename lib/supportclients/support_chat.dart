import 'package:flutter/material.dart';
import 'support_style.dart';

class SupportChat extends StatelessWidget {
  const SupportChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Support', style: merriweatherBold),
        backgroundColor: vertPrimaire,
        foregroundColor: blanc,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: const [
                _Message(isUser: false, texte: "Bonjour, comment puis-je vous aider ?"),
                _Message(isUser: true, texte: "J'ai un problème avec ma réservation."),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Tapez votre message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: vertPrimaire),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final bool isUser;
  final String texte;

  const _Message({required this.isUser, required this.texte});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? vertPrimaire : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(texte, style: merriweatherNormal.copyWith(
          color: isUser ? blanc : noir,
        )),
      ),
    );
  }
}