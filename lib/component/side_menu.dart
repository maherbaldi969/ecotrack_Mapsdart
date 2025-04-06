import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import '../chat/chat_list_screen.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  int selectedIndex = 0;
  final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false); // Gérer le mode sombre

  final List<MenuItem> menuItems = [
    MenuItem(icon: Icons.message, title: "Chat liste"),
    MenuItem(icon: Icons.help, title: "Help"),
    MenuItem(icon: Icons.info, title: "About Us"),
    MenuItem(icon: Icons.star, title: "Rate Us"),
  ];

  @override
  void dispose() {
    isDarkModeNotifier.dispose(); // Nettoyer le ValueNotifier
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark; // Déterminer le mode sombre

    return Scaffold(
      body: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : Colors.white, // Utiliser isDarkMode
                gradient: LinearGradient(
                  colors: [Color(0xFF80C000), Color(0xFF8B8787)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      ZoomDrawer.of(context)?.toggle();
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 30,
                        child: Icon(Icons.person, color: Colors.black, size: 30),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Mohamed aziz", style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Merriweather",
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: selectedIndex == index ? Color(0xFF80C000) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: selectedIndex == index ? [
                            BoxShadow(
                              color: Colors.black,
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ] : [],
                        ),
                        child: ListTile(
                          leading: Icon(menuItems[index].icon,
                              color: selectedIndex == index ? Colors.white : Colors.black),
                          title: Text(menuItems[index].title, style: TextStyle(
                            color: selectedIndex == index ? Colors.white : Colors.black,
                            fontFamily: "Merriweather",
                          )),
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                            if (menuItems[index].title == "Chat liste") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ChatListScreen()),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Light", style: TextStyle(color: Colors.white, fontFamily: "Merriweather")),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          // Basculer entre les modes sombre et clair
                          isDarkModeNotifier.value = !isDarkModeNotifier.value;
                          // Mettre à jour le thème de l'application
                          if (isDarkModeNotifier.value) {
                            // Activer le mode sombre
                            // Vous pouvez utiliser `ThemeMode.dark` dans votre `MaterialApp` pour gérer cela.
                          } else {
                            // Activer le mode clair
                            // Vous pouvez utiliser `ThemeMode.light` dans votre `MaterialApp` pour gérer cela.
                          }
                        },
                        child: ValueListenableBuilder<bool>(
                          valueListenable: isDarkModeNotifier,
                          builder: (context, isDarkMode, child) {
                            return AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              width: 50,
                              height: 25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: isDarkMode ? Colors.black : Colors.white,
                              ),
                              child: Stack(
                                children: [
                                  AnimatedPositioned(
                                    duration: Duration(milliseconds: 300),
                                    left: isDarkMode ? 25 : 0,
                                    right: isDarkMode ? 0 : 25,
                                    child: Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: CircleAvatar(
                                        backgroundColor: isDarkMode ? Colors.white : Colors.yellow,
                                        child: Icon(
                                          isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                                          color: isDarkMode ? Colors.black : Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Text("Dark", style: TextStyle(color: Colors.white, fontFamily: "Merriweather")),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.logout, color: Colors.black),
                        SizedBox(width: 10),
                        Text("Logout", style: TextStyle(
                          color: Colors.black, fontFamily: "Merriweather",
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MenuItem {
  final IconData icon;
  final String title;

  MenuItem({required this.icon, required this.title});
}