import 'package:flutter/material.dart';
import 'settings_page.dart';
import '../navigationetsuivi/Maps.dart'; // Assurez-vous d'importer votre fichier Maps.dart
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Importez LatLng

class ChatScreen extends StatelessWidget {
  final String user;
  final List<Map<String, dynamic>> messages; // Liste des messages
  final Function(String, String) onSendMessage; // Fonction pour envoyer un message
  final Function(double, double) onLocationMessageTap; // Fonction pour gérer le clic sur un message de position

  ChatScreen({
    required this.user,
    required this.messages,
    required this.onSendMessage,
    required this.onLocationMessageTap, 
  });

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Row(
          children: [   
            CircleAvatar(  
              backgroundImage: AssetImage('images/user.png'),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  "Active now",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF80C000),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.video_call),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message['sender'] == 'Vous';
                final isLocationMessage = message['message']?.startsWith('Position partagée:') ?? false;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: isLocationMessage ? () {
                      // Extraire les coordonnées GPS du message
                      final parts = message['message']!.split(': ')[1].split(', ');
                      final latitude = double.parse(parts[0]);
                      final longitude = double.parse(parts[1]);

                      // Créer un objet LatLng avec les coordonnées
                      final position = LatLng(latitude, longitude);

                      // Naviguer vers la carte avec les coordonnées GPS
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapsPage(initialPosition: position), // Utilisez initialPosition
                        ),
                      );
                    } : null,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? Color(0xFF80C000) : Color(0xFFEEEFF3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        message['message']!,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: Colors.grey.shade700),
            onPressed: () {
              _showUploadOptions(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.mic, color: Colors.grey.shade700),
            onPressed: () {
              _startRecording();
            },
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Écrivez un message...',
                filled: true,
                fillColor: Color(0xFFF1F1F1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Color(0xFF80C000)),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                onSendMessage(_controller.text, 'Vous'); // Appeler la fonction pour envoyer un message
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.file_upload, color: Color(0xFF80C000)),
              title: Text('Upload File', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                Navigator.pop(context);
                _uploadFile();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.green),
              title: Text('Take Picture', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                Navigator.pop(context);
                _takePicture();
              },
            ),
            ListTile(
              leading: Icon(Icons.image, color: Color(0xFF80C000)),
              title: Text('Upload Image', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                Navigator.pop(context);
                _uploadImage();
              },
            ),
          ],
        );
      },
    );
  }

  void _uploadFile() {
    print("📂 Upload file...");
  }

  void _takePicture() async {
    print("📸 Picture taken:");
  }

  void _uploadImage() async {
    print("🖼️ Image selected:");
  }

  void _startRecording() {
    print("🎤 Recording started...");
  }
}