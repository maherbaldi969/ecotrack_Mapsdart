import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/itinerary.dart';
import '../models/review.dart';
import '../models/favorites_manager.dart';
import 'package:google_fonts/google_fonts.dart';


class ItineraryDetailScreen extends StatefulWidget {
  final Itinerary itinerary;

  const ItineraryDetailScreen({Key? key, required this.itinerary}) : super(key: key);

  @override
  _ItineraryDetailScreenState createState() => _ItineraryDetailScreenState();
}

class _ItineraryDetailScreenState extends State<ItineraryDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 5;

  void _submitReview() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        widget.itinerary.reviews.add(Review(
          username: 'Utilisateur',
          comment: _commentController.text,
          rating: _selectedRating,
          date: DateTime.now(),
        ));
        _commentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var favoritesManager = Provider.of<FavoritesManager>(context);
    bool isFavorite = favoritesManager.isFavorite(widget.itinerary);

    return Scaffold(
      backgroundColor: const Color(0xFFEEEFF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF80C000),
        title: Text(
          "elguid.com",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () {
              setState(() {
                if (isFavorite) {
                  favoritesManager.removeFromFavorites(widget.itinerary);
                } else {
                  favoritesManager.addToFavorites(widget.itinerary);
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItineraryDetails(),
            const SizedBox(height: 20),
            _buildReviewForm(),
            const SizedBox(height: 20),
            _buildReviewsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildItineraryDetails() {
    return _buildCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.itinerary.name,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.directions_walk, "Distance: ${widget.itinerary.distance} km"),
          _buildInfoRow(Icons.trending_up, "Difficulté: ${widget.itinerary.difficulty}"),
          _buildInfoRow(Icons.timer, "Durée: ${widget.itinerary.duration} min"),
          _buildInfoRow(Icons.terrain, "Altitude: ${widget.itinerary.altitude} m"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF80C000)),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildReviewForm() {
    return _buildCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ajouter un avis',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Note : ',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              DropdownButton<int>(
                value: _selectedRating,
                items: List.generate(5, (index) => index + 1)
                    .map((rating) => DropdownMenuItem(
                    value: rating, child: Text('$rating ⭐')))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRating = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              labelText: 'Votre commentaire',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF80C000),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 130),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Envoyer',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Avis des utilisateurs',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 10),
              if (widget.itinerary.reviews.isEmpty)
                Text(
                  'Aucun avis pour cet itinéraire.',
                  style: GoogleFonts.poppins(color: Colors.grey),
                )
              else
                Column(
                  children: widget.itinerary.reviews.map((review) {
                    return Card(
                      color: const Color(0xFFEEEFF3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.black),
                        title: Text(
                          '${review.username} - ${review.rating} ⭐',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          review.comment,
                          style: GoogleFonts.poppins(color: Colors.black),
                        ),
                        trailing: Text(
                          '${review.date.day}/${review.date.month}/${review.date.year}',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}

