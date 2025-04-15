import 'package:flutter/material.dart';
import 'support_style.dart';
import 'support_api_service.dart';
import 'support_ticket.dart';

class SupportFormulaire extends StatefulWidget {
  const SupportFormulaire({super.key});

  @override
  _SupportFormulaireState createState() => _SupportFormulaireState();
}

class _SupportFormulaireState extends State<SupportFormulaire> {
  final TextEditingController _sujetController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _statutController = TextEditingController();
  final TextEditingController _utilisateurIdController = TextEditingController();

  final SupportApiService _apiService = SupportApiService();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _sujetController.dispose();
    _descriptionController.dispose();
    _statutController.dispose();
    _utilisateurIdController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    setState(() {
      _isSubmitting = true;
    });

    final ticket = SupportTicket(
      id: '',
      sujet: _sujetController.text,
      description: _descriptionController.text,
      statut: _statutController.text,
      utilisateurId: _utilisateurIdController.text,
    );

    try {
      final success = await _apiService.createTicket(ticket);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ticket créé avec succès !', style: merriweatherNormal)),
        );
        _sujetController.clear();
        _descriptionController.clear();
        _statutController.clear();
        _utilisateurIdController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la création du ticket.', style: merriweatherNormal)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: \$e', style: merriweatherNormal)),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

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
              controller: _sujetController,
              decoration: InputDecoration(
                labelText: "Sujet",
                labelStyle: merriweatherNormal,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Description",
                labelStyle: merriweatherNormal,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _statutController,
              decoration: InputDecoration(
                labelText: "Statut",
                labelStyle: merriweatherNormal,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _utilisateurIdController,
              decoration: InputDecoration(
                labelText: "Utilisateur ID",
                labelStyle: merriweatherNormal,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: boutonVert,
              onPressed: _isSubmitting ? null : _submitForm,
              child: _isSubmitting
                  ? CircularProgressIndicator(color: blanc)
                  : const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }
}
