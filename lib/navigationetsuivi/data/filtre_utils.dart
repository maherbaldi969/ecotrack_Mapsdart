import 'package:flutter/material.dart';

/// Utility class for handling filter operations in the navigation application
class FiltreUtils {
  /// List of available filters
  static const List<String> filters = [
    'Distance',
    'Difficulté', 
    'Durée',
    'Altitude'
  ];

  /// Currently selected filter
  static String? selectedFilter;

  /// Builds the filter menu items for a PopupMenuButton
  static List<PopupMenuItem<String>> buildFilterMenuItems(BuildContext context) {
    return filters.map((String filter) {
      return PopupMenuItem<String>(
        value: filter,
        child: Text(filter),
      );
    }).toList();
  }

  /// Handles filter selection and shows a snackbar notification
  static void handleFilterSelection(
    String value, 
    void Function(String) showSnackBar
  ) {
    selectedFilter = value;
    showSnackBar("Filtre sélectionné : $value");
  }
}
