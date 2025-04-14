import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatProvider with ChangeNotifier {
  final String baseUrl = "http://192.168.112.51:3000/api/messages";

  // For testing on your device
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> fetchMessages() async {
    _isLoading = true;
    notifyListeners();
    try {
      print("Fetching messages from: $baseUrl");
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        _messages = data
            .map((message) => {
                  'id': message['id']?.toString() ?? '',
                  'contenu': message['contenu']?.toString() ?? '',
                  'expediteur_id': message['expediteur_id'] ?? 0,
                  'created_at': message['created_at']?.toString() ?? '',
                  'isLocal': false
                })
            .toList();

        print("Messages updated: ${_messages.length} messages loaded");
        _isLoading = false;
        notifyListeners();
      } else {
        print("Failed to fetch messages. Status code: ${response.statusCode}");
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching messages: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String contenu, int expediteurId) async {
    final startTime = DateTime.now();
    final newMessage = {
      'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
      'contenu': contenu,
      'expediteur_id': expediteurId,
      'created_at': DateTime.now().toIso8601String(),
      'isLocal': true
    };

    _messages.add(newMessage);
    notifyListeners();

    try {
      print("Sending message to server...");
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contenu': contenu,
          'expediteur_id': expediteurId,
        }),
      );

      final endTime = DateTime.now();
      print(
          "Message POST duration: ${endTime.difference(startTime).inMilliseconds} ms");

      if (response.statusCode == 201) {
        print("Message sent successfully");
        final index = _messages.indexWhere((m) => m['id'] == newMessage['id']);
        if (index != -1) {
          _messages[index]['isLocal'] = false;
          notifyListeners();
        }
        // Do NOT call await fetchMessages() here to avoid UI blocking
      } else {
        print("Failed to send message: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending message: $e");
    }
  }
}
