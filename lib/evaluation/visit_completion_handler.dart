import 'package:flutter/material.dart';
import 'package:ecotrack/services/notifications_service.dart';
import 'package:ecotrack/evaluation/evaluation_screen.dart';

class VisitCompletionHandler {
  static Future<void> handleVisitCompletion({
    required BuildContext context,
    required String visiteId,
    required String guideId,
    required String userId,
    String? guideName,
    String? visiteDate,
  }) async {
    // Notification immédiate
    // Notification immédiate
    await NotificationsService.showNotification(
      title: "Évaluez votre guide",
      body: "Donnez votre avis sur ${guideName ?? 'votre guide'}",
    );

    // Rappel programmé pour 24h après
    await NotificationsService.scheduleNotification(
      title: "Vous n'avez pas évalué votre guide",
      body: "Votre avis est important pour ${guideName ?? 'votre guide'}",
      delay: const Duration(hours: 24),
    );

    // Navigation vers l'écran d'évaluation si notification cliquée
    // (Géré dans le routeur principal)
  }

  static void navigateFromNotification(BuildContext context, Map<String, String> params) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EvaluationScreen(
          visiteId: params['visiteId']!,
          guideId: params['guideId']!,
          userId: params['userId']!,
          guideName: params['guideName'],
          visiteDate: params['visiteDate'],
        ),
      ),
    );
  }
}
