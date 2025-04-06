import 'package:flutter/material.dart';
import '../alerts/alert_models.dart';

class SafetyTipsCard extends StatelessWidget {
  final List<SafetyAdvice> advices;

  const SafetyTipsCard({
    Key? key,
    required this.advices,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (advices.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Conseils de sécurité',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...advices.map((advice) => ListTile(
            leading: Icon(advice.icon),
            title: Text(advice.title),
            subtitle: Text(advice.description),
            contentPadding: EdgeInsets.zero,
            minLeadingWidth: 24,
          )).toList(),
        ],
      ),
    );
  }
}