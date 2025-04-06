import 'package:flutter/material.dart';

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

              // Avis minimum
              const Text(
                "Avis minimum",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [3, 4, 5]
                    .map((rating) => ChoiceChip(
                  label: Text(
                    "⭐️ $rating+",
                    style: TextStyle(color: minRating == rating.toDouble() ? Colors.white : Colors.black),
                  ),
                  selected: minRating == rating.toDouble(),
                  onSelected: (_) {
                    setState(() {
                      minRating = rating.toDouble();
                    });
                  },
                  selectedColor: const Color(0xFF80C000),
                  backgroundColor: Colors.grey[200],
                ))
                    .toList(),
              ),

              const SizedBox(height: 30),

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
                    onPressed: () => Navigator.pop(context),
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