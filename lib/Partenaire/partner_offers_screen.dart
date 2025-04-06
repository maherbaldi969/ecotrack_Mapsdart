import 'package:flutter/material.dart';

class PartnerOffer {
  final String name;
  final String category;
  final String discount;
  final String description;
  final bool isActivated;

  PartnerOffer({
    required this.name,
    required this.category,
    required this.discount,
    required this.description,
    required this.isActivated,
  });
}

List<PartnerOffer> offers = [
  PartnerOffer(
    name: "Auberge Montagnarde",
    category: "Hébergement",
    discount: "-20% sur votre nuitée",
    description: "Profitez d'une réduction exclusive pour les randonneurs.",
    isActivated: false,
  ),
  PartnerOffer(
    name: "Resto du Randonneur",
    category: "Restaurant",
    discount: "-15% sur votre repas",
    description: "Savourez des plats locaux après votre randonnée !",
    isActivated: false,
  ),
  PartnerOffer(
    name: "Boutique Nature & Aventure",
    category: "Boutique",
    discount: "-10% sur vos achats",
    description: "Équipez-vous pour vos prochaines aventures.",
    isActivated: true, // Already activated
  ),
];

class PartnerOffersScreen extends StatefulWidget {
  @override
  _PartnerOffersScreenState createState() => _PartnerOffersScreenState();
}

class _PartnerOffersScreenState extends State<PartnerOffersScreen> {
  void activateOffer(int index) {
    setState(() {
      offers[index] = PartnerOffer(
        name: offers[index].name,
        category: offers[index].category,
        discount: offers[index].discount,
        description: offers[index].description,
        isActivated: true, // Change status to activated
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${offers[index].name} activée avec succès ! 🎉"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Offres Partenaires"),
        backgroundColor: Color(0xFF80C000),
      ),
      body: ListView.builder(
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          return Card(
            margin: EdgeInsets.all(10),
            color: offer.isActivated ? Colors.green[100] : Colors.white,
            child: ListTile(
              leading: Icon(
                offer.isActivated ? Icons.check_circle : Icons.local_offer,
                color: offer.isActivated ? Colors.green : Colors.orange,
                size: 30,
              ),
              title: Text(
                offer.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "${offer.discount} - ${offer.category}",
                style: TextStyle(color: Colors.black54),
              ),
              trailing: offer.isActivated
                  ? Text("✅ Activée", style: TextStyle(color: Colors.green))
                  : ElevatedButton(
                onPressed: () => activateOffer(index),
                child: Text("Activer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF80C000),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PartnerOfferDetails(offer),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
class PartnerOfferDetails extends StatefulWidget {
  final PartnerOffer offer;

  PartnerOfferDetails(this.offer);

  @override
  _PartnerOfferDetailsState createState() => _PartnerOfferDetailsState();
}

class _PartnerOfferDetailsState extends State<PartnerOfferDetails> {
  TextEditingController reviewController = TextEditingController();
  bool reviewSubmitted = false;

  void submitReview() {
    setState(() {
      reviewSubmitted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Merci pour votre avis ! ⭐"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.offer.name),
        backgroundColor: Color(0xFF80C000),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.offer.category,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              widget.offer.discount,
              style: TextStyle(fontSize: 20, color: Colors.green),
            ),
            SizedBox(height: 20),
            Text(widget.offer.description),
            SizedBox(height: 30),
            if (widget.offer.isActivated)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Laissez un avis :",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: reviewController,
                    decoration: InputDecoration(
                      hintText: "Écrivez votre avis ici...",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: reviewSubmitted ? null : submitReview,
                    child: Text("Envoyer"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              )
            else
              Text(
                "🔒 Activez cette offre pour laisser un avis.",
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
