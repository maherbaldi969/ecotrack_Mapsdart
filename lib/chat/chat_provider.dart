import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  List<Map<String, String>> messages = [];

  void sendMessage(String message, String sender) {
    messages.add({'sender': sender, 'message': message});
    notifyListeners(); // Refresh UI
  }

  void resetChat() {
    messages.clear();
    notifyListeners();
  }
}