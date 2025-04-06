import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/progModels.dart';
class GuideReviewsPage extends StatelessWidget {
  final progModels Progs;
  const GuideReviewsPage(this.Progs, {super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF80C000),
        foregroundColor: Colors.white,
        title: Text('Avis sur le Guide',
            style: GoogleFonts.merriweather(color: Colors.white)),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GuideInfoSection(Progs),
            SizedBox(height: 10),
            ReviewFilters(),
            Expanded(child: ReviewsList()),
            DownloadReviewsButton(),
          ],
        ),
      ),
    );
  }
}

class GuideInfoSection extends StatelessWidget {
  final progModels Progs;
  const GuideInfoSection(this.Progs, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage(Progs.icon),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Progs.nom,
                  style: GoogleFonts.merriweather(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 4),
              Text('Les langues parlées :${Progs.langues}',
                  style: GoogleFonts.merriweather(color: Colors.white70, fontSize: 14)),
              SizedBox(height: 4),
              Text('Experiance : ${Progs.experience.toString()}',
                  style: GoogleFonts.merriweather(color: Colors.white70, fontSize: 14)),
              SizedBox(height: 4),
              Row(
                children: List.generate(5, (index) => Icon(Icons.star, color: Colors.yellow, size: 20)),
              )
            ],
          )
        ],
      ),
    );
  }
}

class ReviewFilters extends StatefulWidget {
  @override
  _ReviewFiltersState createState() => _ReviewFiltersState();
}

class _ReviewFiltersState extends State<ReviewFilters> {
  String selectedFilter = 'Récents';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Avis des voyageurs',
            style: GoogleFonts.merriweather(fontSize: 18, fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: selectedFilter,
          items: ['Récents', 'Meilleurs', 'Moins bien notés']
              .map((String value) => DropdownMenuItem(value: value, child: Text(value)))
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedFilter = value!;
            });
          },
        )
      ],
    );
  }
}


class ReviewsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, color: Colors.black),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Voyageur ${index + 1}',
                            style: GoogleFonts.merriweather(fontWeight: FontWeight.bold)),
                        Text('Randonnée - Oct 2024',
                            style: GoogleFonts.merriweather(fontSize: 12, color: Colors.grey)),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: List.generate(5, (i) => Icon(Icons.star, color: i < 4 ? Colors.yellow : Colors.grey, size: 18)),
                ),
                SizedBox(height: 4),
                Text('Super guide ! Très professionnel et connaît bien la région.',
                    style: GoogleFonts.merriweather(fontSize: 14)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DownloadReviewsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF80C000),
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.download, color: Colors.white),
          SizedBox(width: 8),
          Text('Télécharger les avis',
              style: GoogleFonts.merriweather(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }
}

