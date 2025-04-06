import 'package:flutter/material.dart';
import 'package:ecotrack/evaluation/evaluation_prompt_dialog.dart';
import 'package:ecotrack/evaluation/notification_service.dart';

class VisitCompletionHandler {
  static Future<void> handleVisitCompletion({
    required BuildContext context,
    required String visiteId,
    required String guideId,
    required String userId,
    String? guideName,
    String? visitDate,
    bool showPrompt = true,
    bool scheduleReminder = true,
  }) async {
    try {
      // 1. Mark visit as completed in local storage/API
      await _markVisitAsCompleted(visiteId);

      // 2. Schedule reminder notification
      if (scheduleReminder) {
        await NotificationService.scheduleReminderNotification(
          title: "Évaluez votre expérience",
          body: "Votre avis aide les futurs voyageurs à choisir leur guide",
          visiteId: visiteId,
          guideId: guideId,
          userId: userId,
          delay: const Duration(hours: 24),
        );
      }

      // 3. Show immediate evaluation prompt
      if (showPrompt && context.mounted) {
        await _showEvaluationPrompt(
          context,
          visiteId,
          guideId,
          userId,
          guideName,
          visitDate,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error in handleVisitCompletion: $e');
      debugPrint('Stack trace: $stackTrace');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erreur lors du traitement de la visite'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  static Future<void> _markVisitAsCompleted(String visiteId) async {
    // Implementation example with shared_preferences:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('visit_$visiteId_completed', true);

    // Or with API call:
    // await ApiService.markVisitCompleted(visiteId);
  }

  static Future<void> _showEvaluationPrompt(
      BuildContext context,
      String visiteId,
      String guideId,
      String userId,
      String? guideName,
      String? visitDate,
      ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EvaluationPromptDialog(
        visiteId: visiteId,
        guideId: guideId,
        userId: userId,
        guideName: guideName,
        visitDate: visitDate,
      ),
    );
  }

  static Future<bool> isVisitCompleted(String visiteId) async {
    // Implementation example:
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getBool('visit_$visiteId_completed') ?? false;

    return false; // Default value
  }

  static Future<void> resetVisitCompletion(String visiteId) async {
    // Implementation example:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.remove('visit_$visiteId_completed');
  }
}