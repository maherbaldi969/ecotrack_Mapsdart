import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'activity.dart';
import 'suggested_programs.dart';

class SelectActivitiesPage extends StatefulWidget {
  final List<Activity> initialSelection;
  final Map<String, dynamic>? preferences;

  const SelectActivitiesPage(this.initialSelection, {super.key, this.preferences});

  @override
  State<SelectActivitiesPage> createState() => _SelectActivitiesPageState();
}

class _SelectActivitiesPageState extends State<SelectActivitiesPage> {
  late List<Activity> selectedActivities;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  bool _showOnlySelected = false;

  final List<Activity> _allActivities = [
    Activity(
      name: "Randonnée en montagne",
      duration: 3,
      category: "Sport",
      iconCode: 'e3eb',
      price: 15.0,
      description: "Randonnée guidée dans les montagnes locales avec vue panoramique",
    ),
    Activity(
      name: "Visite musée d'art",
      duration: 2,
      category: "Culture",
      iconCode: 'e3a9',
      price: 12.5,
      description: "Visite des collections permanentes et expositions temporaires",
    ),
    Activity(
      name: "Dégustation vin local",
      duration: 1,
      category: "Gastronomie",
      iconCode: 'e56c',
      price: 25.0,
      description: "Découverte des vins régionaux avec sommelier expert",
    ),
    Activity(
      name: "Tour de la ville en vélo",
      duration: 2,
      category: "Sport",
      iconCode: 'e52f',
      price: 18.0,
      description: "Visite guidée des principaux sites en vélo électrique",
    ),
    Activity(
      name: "Atelier cuisine locale",
      duration: 3,
      category: "Gastronomie",
      iconCode: 'e56a',
      price: 45.0,
      description: "Apprenez à préparer des plats traditionnels avec un chef",
    ),
    Activity(
      name: "Concert en plein air",
      duration: 2,
      category: "Culture",
      iconCode: 'e405',
      price: 30.0,
      description: "Spectacle de musique traditionnelle en centre-ville",
    ),
  ];

  @override
  void initState() {
    super.initState();
    selectedActivities = List.from(widget.initialSelection);
    _applyPreferences();
  }

  void _applyPreferences() {
    if (widget.preferences != null) {
      final maxDuration = widget.preferences!['maxDuration'] as int;
      final maxBudget = widget.preferences!['maxBudget'] as double;
      final preferredCategories = widget.preferences!['preferredCategories'] as List<String>;

      setState(() {
        _allActivities.removeWhere((activity) =>
        activity.duration > maxDuration ||
            activity.price > maxBudget ||
            (preferredCategories.isNotEmpty && !preferredCategories.contains(activity.category))
        );
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Activity> get _filteredActivities {
    final query = _searchController.text.toLowerCase();
    var activities = _allActivities;

    if (_selectedCategory != null) {
      activities = activities.where((a) => a.category == _selectedCategory).toList();
    }

    if (_showOnlySelected) {
      activities = activities.where((a) => selectedActivities.contains(a)).toList();
    }

    if (query.isNotEmpty) {
      activities = activities.where((a) =>
      a.name.toLowerCase().contains(query) ||
          a.category.toLowerCase().contains(query) ||
          a.description.toLowerCase().contains(query)
      ).toList();
    }

    return activities;
  }

  List<String> get _availableCategories {
    return _allActivities.map((a) => a.category).toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sélection des activités',
          style: GoogleFonts.merriweather(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF80C000),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: () => _showFilterDialog(),
            tooltip: 'Filtres',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une activité...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          _buildCategoryChips(),
          Expanded(
            child: _filteredActivities.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              itemCount: _filteredActivities.length,
              itemBuilder: (context, index) {
                final activity = _filteredActivities[index];
                return _buildActivityItem(activity);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: selectedActivities.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuggestedProgramsPage(selectedActivities),
          ),
        ),
        backgroundColor: const Color(0xFF80C000),
        icon: Icon(Icons.arrow_forward),
        label: Text(
          'Voir les suggestions (${selectedActivities.length})',
          style: GoogleFonts.merriweather(),
        ),
      )
          : null,
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            label: Text('Toutes'),
            selected: _selectedCategory == null,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = null;
              });
            },
          ),
          ..._availableCategories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: FilterChip(
                label: Text(category),
                selected: _selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : null;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Activity activity) {
    final isSelected = selectedActivities.contains(activity);
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showActivityDetails(activity),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF80C000).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(activity.icon,
                    color: Color(0xFF80C000),
                    size: 24),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.name,
                      style: GoogleFonts.merriweather(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          '${activity.duration}h',
                          style: GoogleFonts.merriweather(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.euro_symbol, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          '${activity.price.toStringAsFixed(2)}€',
                          style: GoogleFonts.merriweather(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: isSelected,
                onChanged: (selected) => setState(() {
                  selected!
                      ? selectedActivities.add(activity)
                      : selectedActivities.remove(activity);
                }),
                activeColor: const Color(0xFF80C000),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            _showOnlySelected
                ? "Aucune activité sélectionnée"
                : "Aucune activité trouvée",
            style: GoogleFonts.merriweather(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _showOnlySelected
                ? "Sélectionnez des activités pour continuer"
                : "Essayez de modifier vos critères de recherche",
            style: GoogleFonts.merriweather(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          if (_showOnlySelected) ...[
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _showOnlySelected = false;
                });
              },
              child: Text('Voir toutes les activités'),
            ),
          ],
        ],
      ),
    );
  }

  void _showActivityDetails(Activity activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    activity.name,
                    style: GoogleFonts.merriweather(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    avatar: Icon(Icons.category, size: 16),
                    label: Text(activity.category),
                  ),
                  SizedBox(width: 8),
                  Chip(
                    avatar: Icon(Icons.schedule, size: 16),
                    label: Text('${activity.duration}h'),
                  ),
                  SizedBox(width: 8),
                  Chip(
                    avatar: Icon(Icons.euro_symbol, size: 16),
                    label: Text('${activity.price.toStringAsFixed(2)}€'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Description',
                style: GoogleFonts.merriweather(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                activity.description,
                style: GoogleFonts.merriweather(),
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (selectedActivities.contains(activity)) {
                        selectedActivities.remove(activity);
                      } else {
                        selectedActivities.add(activity);
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    selectedActivities.contains(activity)
                        ? 'Retirer de la sélection'
                        : 'Ajouter à la sélection',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF80C000),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filtrer les activités'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text('Afficher seulement les sélectionnées'),
                value: _showOnlySelected,
                onChanged: (value) {
                  setState(() {
                    _showOnlySelected = value;
                  });
                  Navigator.pop(context);
                },
              ),
              Divider(),
              Text('Filtrer par catégorie:'),
              ..._availableCategories.map((category) {
                return RadioListTile<String?>(
                  title: Text(category),
                  value: category,
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
              RadioListTile<String?>(
                title: Text('Toutes les catégories'),
                value: null,
                groupValue: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = null;
                  _showOnlySelected = false;
                });
                Navigator.pop(context);
              },
              child: Text('Réinitialiser'),
            ),
          ],
        );
      },
    );
  }
}