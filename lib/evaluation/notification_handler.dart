import 'package:flutter/material.dart';
import 'dart:convert';
import 'evaluation_screen.dart';

class NotificationHandler {
  static void handleNotificationClick(BuildContext context, String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      if (context.mounted) {
        EvaluationScreen.navigateFromNotification(
          context,
          visiteId: data['visiteId'] ?? '',
          guideId: data['guideId'] ?? '',
          userId: data['userId'] ?? '',
        );
      }
    } catch (e) {
      debugPrint('Error handling notification: $e');
    }
  }
}