import 'package:flutter/material.dart';
import '../services/tours_service.dart';

class FilterModal extends StatefulWidget {
  const FilterModal({super.key});

  @override
  _FilterModalState createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  String selectedActivity = "";
  List<String> selectedDifficulties = [];
  List<String> selectedLanguages = [];
  double minRating = 3.0;

  double maxDuration = 10; // default max duration in hours
  double maxPrice = 1000; // default max price

  final ToursService toursService = ToursService();

  bool _isLoading = false;
  String? _errorMessage;

  void applyFilters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // For simplicity, only filtering by language, duration, and price as per user request
      String? langue = selectedLanguages.isNotEmpty ? selectedLanguages.first : null;
      int? duree = maxDuration.toInt();
      int? prix = maxPrice.toInt();

      final filteredTours = await toursService.filterTours(
        langue: langue,
        duree: duree,
        prix: prix,
      );

      if (filteredTours.isEmpty) {
        setState(() {
          _errorMessage = "Aucun résultat";
        });
      } else {
        // You would typically pass filteredTours back to the exploration screen or update state accordingly
        print('Filtered tours count: \${filteredTours.length}');
        Navigator.pop(context, filteredTours);
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur lors de l'application des filtres";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'application des filtres')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView( // Ajout de SingleChildScrollView
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bouton retour et barre de fermeture
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF80C000),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 48), // Espace pour équilibrer le bouton retour
                ],
              ),

              const SizedBox(height: 20),

              // Type d'activité
              const Text(
                "Type d’activité",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Wrap(
                spacing: 10,
                children: ["Randonnée", "Visite culturelle", "Aventure"]
                    .map((activity) => ChoiceChip(
                  label: Text(
                    activity,
                    style: TextStyle(color: selectedActivity == activity ? Colors.white : Colors.black),
                  ),
                  selected: selectedActivity == activity,
                  onSelected: (_) {
                    setState(() {
                      selectedActivity = activity;
                    });
                  },
                  selectedColor: const Color(0xFF80C000),
                  backgroundColor: Colors.grey[200],
                ))
                    .toList(),
              ),

              const SizedBox(height: 20),

              // Niveau de difficulté
              const Text(
                "Niveau de difficulté",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Wrap(
                spacing: 10,
                children: ["Facile", "Moyen", "Difficile"]
                    .map((level) => FilterChip(
                  label: Text(
                    level,
                    style: TextStyle(color: selectedDifficulties.contains(level) ? Colors.white : Colors.black),
                  ),
                  selected: selectedDifficulties.contains(level),
                  onSelected: (_) {
                    setState(() {
                      if (selectedDifficulties.contains(level)) {
                        selectedDifficulties.remove(level);
                      } else {
                        selectedDifficulties.add(level);
                      }
                    });
                  },
                  selectedColor: const Color(0xFF80C000),
                  backgroundColor: Colors.grey[200],
                ))
                    .toList(),
              ),

              const SizedBox(height: 20),

              // Langues parlées
              const Text(
                "Langues parlées de Guide",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Wrap(
                spacing: 10,
                children: ["Français", "Anglais", "Arabe"]
                    .map((lang) => FilterChip(
                  label: Text(
                    lang,
                    style: TextStyle(color: selectedLanguages.contains(lang) ? Colors.white : Colors.black),
                  ),
                  selected: selectedLanguages.contains(lang),
                  onSelected: (_) {
                    setState(() {
                      if (selectedLanguages.contains(lang)) {
                        selectedLanguages.remove(lang);
                      } else {
                        selectedLanguages.add(lang);
                      }
                    });
                  },
                  selectedColor: const Color(0xFF80C000),
                  backgroundColor: Colors.grey[200],
                ))
                    .toList(),
              ),

              const SizedBox(height: 20),

              // Durée maximale
              const Text(
                "Durée maximale (heures)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Slider(
                value: maxDuration,
                min: 1,
                max: 24,
                divisions: 23,
                label: maxDuration.round().toString(),
                onChanged: (value) {
                  setState(() {
                    maxDuration = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Prix maximum
              const Text(
                "Prix maximum",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Slider(
                value: maxPrice,
                min: 0,
                max: 5000,
                divisions: 100,
                label: maxPrice.round().toString(),
                onChanged: (value) {
                  setState(() {
                    maxPrice = value;
                  });
                },
              ),

              const SizedBox(height: 30),

              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else if (_errorMessage != null)
                Center(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),

              // Boutons actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedActivity = "";
                        selectedDifficulties.clear();
                        selectedLanguages.clear();
                        minRating = 3.0;
                        maxDuration = 10;
                        maxPrice = 1000;
                        _errorMessage = null;
                      });
                    },
                    child: const Text(
                      "Réinitialiser",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF80C000),
                    ),
                    onPressed: applyFilters,
                    child: const Text("Appliquer", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
