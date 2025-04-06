import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HistoriqueRandonneesPage extends StatelessWidget {
  final List<Map<String, dynamic>> randonnees = [
    {
      'nom': 'Sentier des Cascades',
      'distance': 12.5,
      'temps': '3h 45m',
      'altitude': 850,
      'date': DateTime(2025, 3, 10)
    },
    {
      'nom': 'Mont Ecovert',
      'distance': 8.2,
      'temps': '2h 30m',
      'altitude': 1200,
      'date': DateTime(2025, 3, 8)
    },
    {
      'nom': 'Foret des Lumieres',
      'distance': 15.0,
      'temps': '4h 10m',
      'altitude': 900,
      'date': DateTime(2025, 3, 5)
    },
  ];

  double calculerDistanceTotale() {
    return randonnees.fold(0, (sum, item) => sum + item['distance']);
  }

  int calculerCaloriesBrulees() {
    return (calculerDistanceTotale() * 60).toInt(); // Estimation : 60 kcal/km
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historique des Randonnées',
          style: GoogleFonts.merriweather(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF80C000),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatCard(
                  titre: 'Distance Totale',
                  valeur: '${calculerDistanceTotale().toStringAsFixed(1)} km',
                  icone: Icons.directions_walk,
                ),
                StatCard(
                  titre: 'Calories Brûlées',
                  valeur: '${calculerCaloriesBrulees()} kcal',
                  icone: Icons.local_fire_department,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: randonnees.length,
              itemBuilder: (context, index) {
                final randonnee = randonnees[index];
                return Card(
                  color: Colors.white,
                  margin: EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Color(0xFF80C000), width: 2),
                  ),
                  child: ListTile(
                    title: Text(
                      randonnee['nom'],
                      style: GoogleFonts.merriweather(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      'Distance: ${randonnee['distance']} km | Temps: ${randonnee['temps']}\n'
                          'Altitude: ${randonnee['altitude']} m\n'
                          'Date: ${DateFormat('dd/MM/yyyy').format(randonnee['date'])}',
                      style: GoogleFonts.merriweather(
                        color: Colors.black,
                      ),
                    ),
                    leading: Icon(Icons.terrain, color: Color(0xFF80C000)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String titre;
  final String valeur;
  final IconData icone;

  const StatCard({
    required this.titre,
    required this.valeur,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Color(0xFF80C000), width: 2),
      ),
      child: ListTile(
        leading: Icon(icone, color: Color(0xFF80C000), size: 30),
        title: Text(
          titre,
          style: GoogleFonts.merriweather(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          valeur,
          style: GoogleFonts.merriweather(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}