import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';

class OfflineMapPage extends StatefulWidget {
  @override
  OfflineMapPageState createState() => OfflineMapPageState();
}

class OfflineMapPageState extends State<OfflineMapPage> {
  String mapFilePath = "";
  String wordpressMapUrl = "https://yourwordpresssite.com/wp-json/wp/v2/media/your_map_image_id";

  @override
  void initState() {
    super.initState();
    _fetchMapFromWordPress();
  }

  Future<void> _fetchMapFromWordPress() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/map_tile.png';

      Response response = await Dio().get(
        wordpressMapUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      File file = File(filePath);
      await file.writeAsBytes(response.data);

      setState(() {
        mapFilePath = filePath;
      });
    } catch (e) {
      print("Erreur lors du téléchargement de la carte depuis WordPress: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center( // Centrer le texte
          child: Text(
            "Carte Hors Ligne",
            style: GoogleFonts.merriweather(
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20.0, // Augmenter la taille du texte
              ),
            ),
          ),
        ),
        backgroundColor: Color(0xFF80C000),
        elevation: 4,
      ),
      body: Center(
        child: mapFilePath.isNotEmpty
            ? Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(mapFilePath),
              fit: BoxFit.cover,
            ),
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              "Aucune carte enregistrée",
              style: GoogleFonts.merriweather(
                textStyle: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
