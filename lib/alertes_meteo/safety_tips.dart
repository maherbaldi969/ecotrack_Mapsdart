import 'package:flutter/material.dart';
import 'weather_style.dart';

class SafetyTips extends StatelessWidget {
  final Map<String, dynamic> alert;

  const SafetyTips({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Conseils de sécurité',
            style: merriweatherBold.copyWith(fontSize: 18)),
        const SizedBox(height: 8),
        ..._getTipsForAlert(alert).map((tip) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(child: Text(tip, style: merriweatherNormal)),
                ],
              ),
            )),
      ],
    );
  }

  List<String> _getTipsForAlert(Map<String, dynamic> alert) {
    final severity = alert['severity']?.toString().toLowerCase() ?? '';
    final event = alert['event']?.toString().toLowerCase() ?? '';

    if (severity.contains('extreme')) {
      return [
        'Évitez toute activité en extérieur',
        'Restez dans un abri sécurisé',
        'Suivez les instructions des autorités locales'
      ];
    }

    if (event.contains('pluie') || event.contains('inondation')) {
      return [
        'Évitez les zones basses',
        'Ne traversez pas les routes inondées',
        'Portez des vêtements imperméables'
      ];
    }

    if (event.contains('chaleur')) {
      return [
        'Restez hydraté',
        'Évitez les activités entre 11h et 15h',
        'Portez des vêtements légers et clairs'
      ];
    }

    return [
      'Vérifiez votre équipement',
      'Informez quelqu\'un de votre itinéraire',
      'Emportez une trousse de premiers soins'
    ];
  }
}
