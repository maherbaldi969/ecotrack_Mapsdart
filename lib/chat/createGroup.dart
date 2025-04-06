import 'package:flutter/material.dart';

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> users = [
    {'name': 'Bâldi Mâher', 'image': 'images/user.png', 'selected': false},
    {'name': "Elwefi Salem", 'image': 'images/user.png', 'selected': false},
    {'name': 'Monta Sar', 'image': 'images/user.png', 'selected': false},
    {'name': 'Motaz Mohammed', 'image': 'images/user.png', 'selected': false},
  ];

  List<Map<String, dynamic>> selectedUsers = [];

  void toggleUserSelection(int index) {
    setState(() {
      users[index]['selected'] = !users[index]['selected'];
      if (users[index]['selected']) {
        selectedUsers.add(users[index]);
      } else {
        selectedUsers.removeWhere((user) => user['name'] == users[index]['name']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Nouveau groupe', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: selectedUsers.isNotEmpty ? () {} : null,
            child: Text('Créer',
                style: TextStyle(
                    color: selectedUsers.isNotEmpty ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(labelText: 'Nom du groupe (facultatif)'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Rechercher',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 10),
            selectedUsers.isNotEmpty
                ? SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedUsers.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: CircleAvatar(
                              backgroundImage: AssetImage(selectedUsers[index]['image']),
                              radius: 30,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  users.firstWhere((user) => user['name'] == selectedUsers[index]['name'])['selected'] = false;
                                  selectedUsers.removeAt(index);
                                });
                              },
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.close, size: 14, color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        selectedUsers[index]['name'],
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
              ),
            )
                : Container(),
            SizedBox(height: 10),
            Text('Suggestions', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(users[index]['image']),
                    ),
                    title: Text(users[index]['name']),
                    trailing: users[index]['selected']
                        ? const Icon(Icons.radio_button_checked, color: Color(0xFF80C000))
                        : const Icon(Icons.radio_button_unchecked),
                    onTap: () => toggleUserSelection(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
