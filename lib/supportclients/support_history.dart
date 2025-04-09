import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'support_style.dart';

class SupportHistory extends StatelessWidget {
  final List<SupportInteraction> interactions = [
    SupportInteraction(
      type: InteractionType.chat,
      date: DateTime.now().subtract(const Duration(days: 1)),
      summary: "Problème de réservation",
      status: InteractionStatus.resolved,
    ),
    SupportInteraction(
      type: InteractionType.call,
      date: DateTime.now().subtract(const Duration(days: 3)),
      summary: "Question sur un guide",
      status: InteractionStatus.pending,
    ),
    SupportInteraction(
      type: InteractionType.form,
      date: DateTime.now().subtract(const Duration(days: 5)),
      summary: "Problème technique",
      status: InteractionStatus.closed,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des interactions', style: merriweatherBold),
        backgroundColor: vertPrimaire,
        foregroundColor: blanc,
      ),
      body: ListView.builder(
        itemCount: interactions.length,
        itemBuilder: (context, index) {
          final interaction = interactions[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(
                _getInteractionIcon(interaction.type),
                color: _getStatusColor(interaction.status),
              ),
              title: Text(interaction.summary, style: merriweatherBold),
              subtitle: Text(
                DateFormat('dd/MM/yyyy HH:mm').format(interaction.date),
                style: merriweatherNormal,
              ),
              trailing: Chip(
                label: Text(
                  _getStatusText(interaction.status),
                  style: TextStyle(color: blanc),
                ),
                backgroundColor: _getStatusColor(interaction.status),
              ),
              onTap: () {
                // Navigation vers les détails de l'interaction
              },
            ),
          );
        },
      ),
    );
  }

  IconData _getInteractionIcon(InteractionType type) {
    switch (type) {
      case InteractionType.chat:
        return Icons.chat;
      case InteractionType.call:
        return Icons.call;
      case InteractionType.form:
        return Icons.assignment;
    }
  }

  Color _getStatusColor(InteractionStatus status) {
    switch (status) {
      case InteractionStatus.pending:
        return Colors.orange;
      case InteractionStatus.resolved:
        return Colors.green;
      case InteractionStatus.closed:
        return Colors.grey;
    }
  }

  String _getStatusText(InteractionStatus status) {
    switch (status) {
      case InteractionStatus.pending:
        return 'En cours';
      case InteractionStatus.resolved:
        return 'Résolu';
      case InteractionStatus.closed:
        return 'Clôturé';
    }
  }
}

enum InteractionType { chat, call, form }
enum InteractionStatus { pending, resolved, closed }

class SupportInteraction {
  final InteractionType type;
  final DateTime date;
  final String summary;
  final InteractionStatus status;

  SupportInteraction({
    required this.type,
    required this.date,
    required this.summary,
    required this.status,
  });
}
