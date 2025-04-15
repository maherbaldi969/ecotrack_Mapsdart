import 'package:flutter/material.dart';
import 'support_style.dart';
import 'support_api_service.dart';
import 'support_ticket.dart';

class SupportHistory extends StatefulWidget {
  const SupportHistory({super.key});

  @override
  _SupportHistoryState createState() => _SupportHistoryState();
}

class _SupportHistoryState extends State<SupportHistory> {
  final SupportApiService _apiService = SupportApiService();
  late Future<List<SupportTicket>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = _apiService.fetchTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des tickets', style: merriweatherBold),
        backgroundColor: vertPrimaire,
        foregroundColor: blanc,
      ),
      body: FutureBuilder<List<SupportTicket>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: \${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun ticket trouvé.'));
          } else {
            final tickets = snapshot.data!;
            return ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.assignment,
                      color: _getStatusColor(ticket.statut),
                    ),
                    title: Text(ticket.sujet, style: merriweatherBold),
                    subtitle: Text(
                      ticket.description,
                      style: merriweatherNormal,
                    ),
                    trailing: Chip(
                      label: Text(
                        ticket.statut,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: _getStatusColor(ticket.statut),
                    ),
                    onTap: () {
                      // TODO: Navigate to ticket details if needed
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Color _getStatusColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'en cours':
      case 'pending':
        return Colors.orange;
      case 'résolu':
      case 'resolved':
        return Colors.green;
      case 'clôturé':
      case 'closed':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }
}
