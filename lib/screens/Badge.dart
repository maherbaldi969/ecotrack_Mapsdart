import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class Badge {
  final String name;
  final String icon;
  final String description;
  final bool isEarned;
  final String reward;

  Badge({
    required this.name,
    required this.icon,
    required this.description,
    required this.isEarned,
    required this.reward,
  });
}

List<Badge> badges = [
  Badge(
    name: "Première randonnée",
    icon: "images/prog1.jpg",
    description: "Badge obtenu après votre première randonnée !",
    isEarned: true,
    reward: "10% de réduction sur votre prochaine réservation",
  ),
  Badge(
    name: "Explorateur culturel",
    icon: "images/prog2.jpg",
    description: "Visitez 5 sites culturels pour débloquer ce badge.",
    isEarned: false,
    reward: "Accès exclusif à des événements culturels",
  ),
  Badge(
    name: "Aventurier du Nord-Ouest",
    icon: "images/prog3.jpg",
    description: "Participez à 3 randonnées en montagne.",
    isEarned: true,
    reward: "Réduction de 15% sur votre prochaine aventure",
  ),
];

class BadgeScreen extends StatelessWidget {
  const BadgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mes Badges",
          style:  GoogleFonts.merriweather(fontSize: 18 , color: Colors.white,),),
        backgroundColor: Color(0xFF80C000),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            return Card(
              color: badge.isEarned ? Colors.white : Colors.grey[300],
              child: ListTile(
                leading: Image.asset(
                  badge.icon,
                  width: 50,
                  height: 50,
                  color: badge.isEarned ? null : Colors.black26,
                ),
                title: Text(
                  badge.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: badge.isEarned ? Colors.black : Colors.black38,
                  ),
                ),
                subtitle: Text(
                  badge.isEarned
                      ? "🎉 Gagné - ${badge.reward}"
                      : "🔒 Non débloqué",
                  style: TextStyle(
                    color: badge.isEarned ? Colors.green : Colors.red,
                  ),
                ),
                onTap: badge.isEarned
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BadgeDetailScreen(badge),
                    ),
                  );
                }
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
class BadgeDetailScreen extends StatelessWidget {
  final Badge badge;

  const BadgeDetailScreen(this.badge, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(badge.name),
        backgroundColor: Color(0xFF80C000),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              badge.icon,
              width: 100,
              height: 100,
            ),
            SizedBox(height: 20),
            Text(
              badge.description,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            if (badge.isEarned)
              Column(
                children: [
                  Text(
                    "🎁 Récompense : ${badge.reward}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Logic for sharing the badge (to be implemented)
                    },
                    icon: Icon(Icons.share),
                    label: Text("Partager sur les réseaux"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF80C000),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

