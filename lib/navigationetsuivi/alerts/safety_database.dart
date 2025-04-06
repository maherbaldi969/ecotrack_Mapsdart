import 'package:flutter/material.dart';
import 'alert_models.dart';

class SafetyDatabase {
  static final Map<String, List<SafetyAdvice>> _adviceDatabase = {
    'orage': [
      SafetyAdvice(
        title: 'Abri sécurisé',
        description: 'Cherchez immédiatement un abri en dur',
        icon: Icons.home,
      ),
      SafetyAdvice(
        title: 'Évitez les arbres',
        description: 'Ne vous abritez pas sous des arbres isolés',
        icon: Icons.nature,
      ),
    ],
    'pluie': [
      SafetyAdvice(
        title: 'Vêtements imperméables',
        description: 'Mettez des vêtements imperméables',
        icon: Icons.water_drop, // Icône alternative pour la pluie
      ),
    ],
    'chaleur': [
      SafetyAdvice(
        title: 'Hydratation',
        description: 'Buvez au moins 2L d\'eau par heure',
        icon: Icons.local_drink,
      ),
      SafetyAdvice(
        title: 'Protection solaire',
        description: 'Appliquez de la crème solaire régulièrement',
        icon: Icons.wb_sunny,
      ),
    ],
    'neige': [
      SafetyAdvice(
        title: 'Équipement chaud',
        description: 'Portez plusieurs couches de vêtements',
        icon: Icons.ac_unit,
      ),
    ],
  };

  static List<SafetyAdvice> getAdvicesForCondition(String condition) {
    return _adviceDatabase[condition.toLowerCase()] ?? [
      SafetyAdvice(
        title: 'Conditions normales',
        description: 'Profitez de votre randonnée en toute sécurité',
        icon: Icons.check_circle,
      ),
    ];
  }

  static List<SafetyAdvice> getDefaultAdvices() {
    return [
      SafetyAdvice(
        title: 'Numéro d\'urgence',
        description: 'Composez le 190 pour les urgences',
        icon: Icons.emergency,
      ),
      SafetyAdvice(
        title: 'Premiers secours',
        description: 'Ayez toujours une trousse de premiers soins',
        icon: Icons.medical_services,
      ),
      SafetyAdvice(
        title: 'Localisation',
        description: 'Partagez votre position avec un proche',
        icon: Icons.location_on,
      ),
    ];
  }
}