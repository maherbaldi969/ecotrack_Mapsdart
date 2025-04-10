import 'package:ecotrack/explore/reserver.dart';
import 'package:flutter/material.dart';
import '../chat/chat_screen.dart';
import '../models/progModels.dart';
import 'guideDetails.dart';

class SelectGuidePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<progModels> guides = progModels.Progs();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sélection d’un Guide',
          style: TextStyle(fontFamily: 'Merriweather', color: Colors.white,fontSize: 18),
        ),
        backgroundColor: Color(0xFF80C000),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: guides.length,
        itemBuilder: (context, index) {
          final guide = guides[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => GuideReviewsPage(guide)),
                      );
                    },
                    child: Image.asset(
                      guide.icon,
                      width: 80,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guide.nom,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Merriweather',
                          ),
                        ),
                        Text('Expérience : ${guide.experience}',
                            style: TextStyle(fontFamily: 'Merriweather')),
                        Text('Langues : ${guide.langues}',
                            style: TextStyle(fontFamily: 'Merriweather')),
                        Row(
                          children: List.generate(
                            5,
                                (i) => Icon(
                              Icons.star,
                              color: i < guide.avis ? Colors.amber : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                user: guide.nom, // Replace with actual user data
                                messages: [], // Provide an empty list or fetch messages
                                onSendMessage: (message, sender) {}, // Dummy function
                                onLocationMessageTap: (lat, lng) {}, // Dummy function
                              ),
                            ),
                          );
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Contacter'),
                      ),
                      SizedBox(height: 5),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ReservationPage(),
                          ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF80C000),
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Réserver'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}