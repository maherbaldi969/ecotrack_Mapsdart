import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/itinerary.dart';
import 'package:google_fonts/google_fonts.dart';


class ItineraryListScreen extends StatefulWidget {
  const ItineraryListScreen({Key? key}) : super(key: key);

  @override
  _ItineraryListScreenState createState() => _ItineraryListScreenState();
}

class _ItineraryListScreenState extends State<ItineraryListScreen> {
  final List<Itinerary> itineraries = [
    Itinerary(name: 'Randonnée Montagne', distance: 5.4, difficulty: 'Moyenne', duration: 120, altitude: 600, location: LatLng(36.9541, 8.7581)),
    Itinerary(name: 'Sentier Forêt', distance: 8.2, difficulty: 'Facile', duration: 180, altitude: 300, location: LatLng(36.9471, 8.7572)),
    Itinerary(name: 'Chemin Escarpé', distance: 10.5, difficulty: 'Difficile', duration: 240, altitude: 900, location: LatLng(36.9491, 8.7555)),
  ];

  double selectedDistance = 15;
  double selectedDuration = 300;
  double selectedAltitude = 1000;
  String selectedDifficulty = 'Tous';

  @override
  Widget build(BuildContext context) {
    List<Itinerary> filteredItineraries = itineraries.where((itinerary) {
      return (itinerary.distance <= selectedDistance) &&
          (itinerary.duration <= selectedDuration) &&
          (itinerary.altitude <= selectedAltitude) &&
          (selectedDifficulty == 'Tous' || itinerary.difficulty == selectedDifficulty);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Itinéraires Disponibles',
          style: GoogleFonts.poppins(), // Utilisation de Google Fonts
        ),
        backgroundColor: const Color(0xFF80C000), // Vert
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItineraries.length,
              itemBuilder: (context, index) {
                final itinerary = filteredItineraries[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  color: const Color(0xFF1E1E1E), // Fond sombre
                  child: ListTile(
                    title: Text(
                      itinerary.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${itinerary.distance} km - ${itinerary.difficulty} - ${itinerary.duration} min - Altitude: ${itinerary.altitude}m',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[300],
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/itineraryDetail', arguments: itinerary);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1E1E1E), // Fond sombre
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Row(
            children: [
              Text('Difficulté: ', style: GoogleFonts.poppins(color: Colors.white)),
              DropdownButton<String>(
                value: selectedDifficulty,
                items: ['Tous', 'Facile', 'Moyenne', 'Difficile']
                    .map((difficulty) => DropdownMenuItem(
                  value: difficulty,
                  child: Text(
                    difficulty,
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDifficulty = value!;
                  });
                },
                dropdownColor: const Color(0xFF333333),
              ),
            ],
          ),
          _buildSlider('Distance (km)', selectedDistance, 1, 20, (value) {
            setState(() {
              selectedDistance = value;
            });
          }),
          _buildSlider('Durée (min)', selectedDuration, 30, 600, (value) {
            setState(() {
              selectedDuration = value;
            });
          }),
          _buildSlider('Altitude (m)', selectedAltitude, 100, 1500, (value) {
            setState(() {
              selectedAltitude = value;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toInt()}', style: GoogleFonts.poppins(color: Colors.white)),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) / 10).toInt(),
          label: value.toInt().toString(),
          onChanged: onChanged,
          activeColor: const Color(0xFF80C000), // Vert
          inactiveColor: Colors.grey,
        ),
      ],
    );
  }
}
