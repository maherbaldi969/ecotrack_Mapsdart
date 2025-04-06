import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  _PreferencesPageState createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  int _availableTime = 4; // heures par défaut
  double _maxBudget = 50.0; // euros par défaut
  final List<String> _categories = ['Sport', 'Culture', 'Gastronomie', 'Nature', 'Aventure'];
  final List<String> _selectedCategories = [];
  bool _budgetFlexible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Préférences du programme',
          style: GoogleFonts.merriweather(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF80C000),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configurez vos préférences pour des suggestions personnalisées',
              style: GoogleFonts.merriweather(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),

            // Section Durée
            _buildSectionTitle('Durée disponible'),
            Slider(
              value: _availableTime.toDouble(),
              min: 1,
              max: 12,
              divisions: 11,
              label: '$_availableTime heure${_availableTime > 1 ? 's' : ''}',
              onChanged: (value) {
                setState(() {
                  _availableTime = value.toInt();
                });
              },
              activeColor: const Color(0xFF80C000),
              inactiveColor: Colors.grey[300],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1 heure', style: GoogleFonts.merriweather()),
                Text('12 heures', style: GoogleFonts.merriweather()),
              ],
            ),
            const SizedBox(height: 30),

            // Section Budget
            _buildSectionTitle('Budget maximum'),
            Slider(
              value: _maxBudget,
              min: 0,
              max: 200,
              divisions: 20,
              label: '${_maxBudget.toStringAsFixed(0)}€',
              onChanged: (value) {
                setState(() {
                  _maxBudget = value;
                });
              },
              activeColor: const Color(0xFF80C000),
              inactiveColor: Colors.grey[300],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0€', style: GoogleFonts.merriweather()),
                Text('200€', style: GoogleFonts.merriweather()),
              ],
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: Text(
                'Budget flexible',
                style: GoogleFonts.merriweather(),
              ),
              subtitle: Text(
                'Autoriser des suggestions légèrement au-dessus du budget',
                style: GoogleFonts.merriweather(fontSize: 12),
              ),
              value: _budgetFlexible,
              onChanged: (value) {
                setState(() {
                  _budgetFlexible = value;
                });
              },
              activeColor: const Color(0xFF80C000),
            ),
            const SizedBox(height: 30),

            // Section Catégories
            _buildSectionTitle('Catégories préférées'),
            Text(
              'Sélectionnez au moins une catégorie pour des suggestions ciblées',
              style: GoogleFonts.merriweather(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                  selectedColor: const Color(0xFF80C000).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF80C000),
                  labelStyle: GoogleFonts.merriweather(
                    color: isSelected ? const Color(0xFF80C000) : Colors.black,
                  ),
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF80C000) : Colors.grey,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            // Bouton de validation
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedCategories.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Veuillez sélectionner au moins une catégorie',
                          style: GoogleFonts.merriweather(),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context, {
                    'maxDuration': _availableTime,
                    'maxBudget': _maxBudget,
                    'preferredCategories': _selectedCategories,
                    'budgetFlexible': _budgetFlexible,
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 16.0,
                  ),
                  child: Text(
                    'Appliquer les préférences',
                    style: GoogleFonts.merriweather(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF80C000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 5,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.merriweather(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}