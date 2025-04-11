import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'createGroup.dart';

class ChatListScreen extends StatefulWidget {
  final bool isSelectingGuide;

  ChatListScreen({this.isSelectingGuide = false});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _chats = [
    {
      'name': 'Guide 1',
      'image': 'images/user.png',
      'isActive': true,
      'hasUnread': true
    },
    {
      'name': 'Guide 2',
      'image': 'images/user.png',
      'isActive': false,
      'hasUnread': false
    },
    {
      'name': 'Guide 3',
      'image': 'images/user.png',
      'isActive': true,
      'hasUnread': false
    },
  ];

  List<Map<String, dynamic>> _filteredChats = [];

  @override
  void initState() {
    super.initState();
    _filteredChats = List.from(_chats);
    _searchController.addListener(_filterChats);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _filterChats() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredChats = _chats
          .where((chat) => chat['name'].toLowerCase().contains(query))
          .toList();
    });
  }

  void _showUserOptions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateGroupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sélectionner un guide'),
        backgroundColor: Color(0xFF80C000),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher un guide',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: ListView.builder(
                itemCount: _filteredChats.length,
                itemBuilder: (context, index) {
                  var chat = _filteredChats[index];
                  return _buildChatTile(
                    context,
                    chat['name'],
                    chat['image'],
                    chat['isActive'],
                    chat['hasUnread'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserOptions(context),
        child: Icon(Icons.group_add),
        backgroundColor: Color(0xFF80C000),
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, String userName, String imagePath,
      bool isActive, bool hasUnread) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(imagePath),
            ),
            if (isActive)
              Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  radius: 6,
                  backgroundColor: Color(0xFF80C000),
                ),
              ),
          ],
        ),
        title: Text(userName),
        trailing: hasUnread
            ? Icon(Icons.circle, color: Color(0xFF80C000), size: 10)
            : null,
        onTap: () {
          if (widget.isSelectingGuide) {
            Navigator.pop(context, {'name': userName, 'image': imagePath});
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  user: userName,
                  messages: [],
                  onSendMessage: (message, sender) {
                    print("Message envoyé : $message par $sender");
                  },
                  onLocationMessageTap: (latitude, longitude) {
                    print(
                        "Clic sur un message de position : $latitude, $longitude");
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
