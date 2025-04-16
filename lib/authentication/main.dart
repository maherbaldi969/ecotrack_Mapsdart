import 'package:flutter/material.dart';
import 'login.dart';
import 'homepage.dart';
import 'session_manager.dart'; //authentication

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: SessionManager.isLoggedIn(),
        builder: (context, snapshot) {
          // Gestion des états de chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Redirection basée sur l'état de connexion
          return snapshot.data == true ? HomePage() : LoginPage();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
