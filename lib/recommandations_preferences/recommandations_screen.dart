import 'package:flutter/material.dart';
import 'package:ecotrack/alertes_meteo/weather_style.dart';
import 'package:ecotrack/services/shared_preferences_service.dart';
import 'package:ecotrack/recommandations_preferences/activity_history_service.dart';
import 'package:ecotrack/recommandations_preferences/recommandations_service.dart';

class RecommandationsScreen extends StatefulWidget {
  const RecommandationsScreen({super.key});

  @override
  State<RecommandationsScreen> createState() => _RecommandationsScreenState();
}

class _RecommandationsScreenState extends State<RecommandationsScreen> {
  final _formKey = GlobalKey<FormState>();
  final RecommandationsService _service;
  final ActivityHistoryService _history;

  _RecommandationsScreenState()
      : _service = RecommandationsService(
            SharedPreferencesService(), ActivityHistoryService()),
        _history = ActivityHistoryService();

  String _activityType = 'Randonnée';
  String _duration = '1-3 jours';
  String _budget = 'Moyen';
  String _language = 'Français';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommandations', style: merriweatherBold),
        backgroundColor: vertPrimaire,
        foregroundColor: blanc,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vos préférences',
                style: merriweatherBold.copyWith(fontSize: 20)),
            const SizedBox(height: 16),
            _buildPreferencesForm(),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: vertPrimaire,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _getRecommandations,
              child: Text('Trouver des recommandations',
                  style: merriweatherBold.copyWith(color: blanc)),
            ),
            const SizedBox(height: 24),
            Text('Suggestions pour vous',
                style: merriweatherBold.copyWith(fontSize: 20)),
            const SizedBox(height: 16),
            _buildRecommandationsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField(
            value: _activityType,
            items: [
              'Randonnée',
              'visites culturelles',
              'camping',
              'Équitation ou randonnée équestre'
            ].map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type, style: merriweatherNormal),
              );
            }).toList(),
            onChanged: (value) =>
                setState(() => _activityType = value.toString()),
            decoration: InputDecoration(
              labelText: 'Type d\'activité',
              labelStyle: merriweatherNormal,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField(
            value: _duration,
            items:
                ['1-3 jours', '4-7 jours', 'Plus d\'une semaine'].map((duree) {
              return DropdownMenuItem(
                value: duree,
                child: Text(duree, style: merriweatherNormal),
              );
            }).toList(),
            onChanged: (value) => setState(() => _duration = value.toString()),
            decoration: InputDecoration(
              labelText: 'Durée',
              labelStyle: merriweatherNormal,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField(
            value: _budget,
            items: ['Économique', 'Moyen', 'Confort', 'Luxe'].map((budget) {
              return DropdownMenuItem(
                value: budget,
                child: Text(budget, style: merriweatherNormal),
              );
            }).toList(),
            onChanged: (value) => setState(() => _budget = value.toString()),
            decoration: InputDecoration(
              labelText: 'Budget',
              labelStyle: merriweatherNormal,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField(
            value: _language,
            items: ['Français', 'Anglais', 'Arabe', 'Allemand'].map((langue) {
              return DropdownMenuItem(
                value: langue,
                child: Text(langue, style: merriweatherNormal),
              );
            }).toList(),
            onChanged: (value) => setState(() => _language = value.toString()),
            decoration: InputDecoration(
              labelText: 'Langue',
              labelStyle: merriweatherNormal,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommandationsList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _service.getPersonalizedRecommandations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: vertPrimaire));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('Aucune recommandation trouvée',
              style: merriweatherNormal);
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: Icon(Icons.recommend, color: vertPrimaire),
                title: Text(item['title'], style: merriweatherBold),
                subtitle: Text(item['description'], style: merriweatherNormal),
                trailing: Icon(Icons.chevron_right, color: noir),
                onTap: () => _showDetails(item),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _getRecommandations() async {
    if (_formKey.currentState!.validate()) {
      final prefs = SharedPreferencesService();
      await prefs.saveUserPreferences(
        activityType: _activityType,
        duration: _duration,
        budget: _budget,
        language: _language,
      );
      setState(() {});
    }
  }

  void _showDetails(Map<String, dynamic> item) {
    _history.recordActivity(item['id'], item['type']);

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(item['title'], style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(item['description']),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  child: const Text('Modifier préférences'),
                  onPressed: () => Navigator.pushNamed(context, '/preferences'),
                ),
                ElevatedButton(
                  child: const Text('Voir détails'),
                  onPressed: () => _navigateToActivityDetails(item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToActivityDetails(Map<String, dynamic> item) {
    // Navigation vers l'écran de détails
  }
}
