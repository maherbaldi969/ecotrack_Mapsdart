import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:record/record.dart';  // Added import for record package
import 'settings_page.dart';
import '../navigationetsuivi/Maps.dart';
import '../services/language_service.dart';
import '../screens/language_selection_screen.dart';
import 'chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String user;
  final Function(double, double) onLocationMessageTap;

  const ChatScreen({
    Key? key,
    required this.user,
    required this.onLocationMessageTap,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late LanguageService _languageService;
  final Map<String, String> _translatedMessages = {};

  final Record _record = Record();  // Record instance added
  bool _isRecording = false;       // Recording state

  @override
  void initState() {
    super.initState();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.fetchMessages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _translateAllMessages();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageService = Provider.of<LanguageService>(context, listen: true);
  }

  Future<void> _translateMessage(String originalText) async {
    if (_translatedMessages.containsKey(originalText)) return;

    final translated = await _languageService.translateText(
        originalText, _languageService.currentLanguage);

    setState(() {
      _translatedMessages[originalText] = translated;
    });
  }

  Future<void> _translateAllMessages() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    for (final message in chatProvider.messages) {
      if (message['contenu'] != null) {
        await _translateMessage(message['contenu']!);
      }
    }
  }

  Future<void> _startRecording() async {
    bool hasPermission = await _record.hasPermission();
    if (!hasPermission) {
      print("Recording permission denied");
      return;
    }
    if (_isRecording) return;

    try {
      await _record.start();
      setState(() {
        _isRecording = true;
      });
      print("Recording started");
    } catch (e) {
      print("Error starting recording: $e");
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      final path = await _record.stop();
      setState(() {
        _isRecording = false;
      });
      print("Recording stopped, file saved at: $path");
      // You can add code here to handle the recorded file path
    } catch (e) {
      print("Error stopping recording: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
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
                  widget.user,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  "Active now",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 29, 0, 192),
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
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                final message = chatProvider.messages[chatProvider.messages.length - 1 - index];
                final isMe = message['expediteur_id'] == 1; // Assuming current user id is 1
                final isLocationMessage =
                    message['contenu']?.startsWith('Position partagée:') ?? false;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: isLocationMessage
                        ? () {
                            final parts =
                                message['contenu']!.split(': ')[1].split(', ');
                            final latitude = double.parse(parts[0]);
                            final longitude = double.parse(parts[1]);

                            final position = LatLng(latitude, longitude);

                            FocusScope.of(context).unfocus();

                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        MapsPage(initialPosition: position),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          }
                        : null,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? Color(0xFF80C000) : Color(0xFFEEEFF3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: GestureDetector(
                        onLongPress: () =>
                            _translateMessage(message['contenu']!),
                        child: Column(
                          children: [
                            Text(
                              message['contenu']!,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            if (_translatedMessages
                                .containsKey(message['contenu']!))
                              Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  _translatedMessages[message['contenu']!]!,
                                  style: TextStyle(
                                    color: isMe
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.black.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildMessageInput(context, chatProvider),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, ChatProvider chatProvider) {
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
            icon: Icon(
              Icons.mic,
              color: _isRecording ? Colors.red : Colors.grey.shade700,
            ),
            onPressed: () {
              if (_isRecording) {
                _stopRecording();
              } else {
                _startRecording();
              }
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
            icon: Icon(Icons.translate, color: Color(0xFF80C000)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LanguageSelectionScreen(),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Color(0xFF80C000)),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                chatProvider.sendMessage(_controller.text, 1); // Assuming current user id is 1
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
              title:
                  Text('Upload File', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                Navigator.pop(context);
                _uploadFile();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.green),
              title:
                  Text('Take Picture', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                Navigator.pop(context);
                _takePicture();
              },
            ),
            ListTile(
              leading: Icon(Icons.image, color: Color(0xFF80C000)),
              title:
                  Text('Upload Image', style: TextStyle(fontFamily: 'Poppins')),
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
}
