import 'signaler_probleme.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 1,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('images/user.png'),
              ),
              const SizedBox(height: 10),
              Text(
                "user",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(icon: Icon(Icons.call, color: isDarkMode ? Colors.white : Colors.black), onPressed: () {}),
                  IconButton(icon: Icon(Icons.videocam, color: isDarkMode ? Colors.white : Colors.black), onPressed: () {}),
                  IconButton(icon: Icon(Icons.person, color: isDarkMode ? Colors.white : Colors.black), onPressed: () {}),
                  IconButton(icon: Icon(Icons.volume_off, color: isDarkMode ? Colors.white : Colors.black), onPressed: () {}),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.remove, color: isDarkMode ? Colors.white : Colors.black),
                      title: Text("Supprimer la conversation",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontFamily: 'Poppins',
                          )),
                    ),
                    ListTile(
                      leading: Icon(Icons.block, color: isDarkMode ? Colors.white : Colors.black),
                      title: Text("Bloquer",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontFamily: 'Poppins',
                          )),
                    ),
                    ListTile(
                      leading: Icon(Icons.feedback, color: isDarkMode ? Colors.white : Colors.black),
                      title: Text(
                        "Signaler un problème",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      onTap: () {
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: "Signaler un problème",
                          transitionDuration: const Duration(milliseconds: 300),
                          pageBuilder: (context, _, __) {
                            return Center(
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  height: 620,
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(40)),
                                  ),
                                  child: SingleChildScrollView(
                                    child: SignalerProblemePage(),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
