import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'OfflineMapPage.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class DownloadMapPage extends StatefulWidget {
  @override
  _DownloadMapPageState createState() => _DownloadMapPageState();
}

class _DownloadMapPageState extends State<DownloadMapPage> {
  String mapFilePath = "";
  bool isDownloading = false;
  double downloadProgress = 0.0;

  Future<void> _downloadAndUploadMap() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/map_tile.png';

    setState(() {
      isDownloading = true;
      downloadProgress = 0.0;
    });

    try {
      await Dio().download(
        "https://maps.googleapis.com/maps/api/staticmap?center=48.858844,2.294351&zoom=15&size=600x300&maptype=terrain&key=YOUR_GOOGLE_MAPS_API_KEY",
        filePath,
        onReceiveProgress: (received, total) {
          setState(() {
            downloadProgress = (received / total);
          });
        },
      );

      setState(() {
        mapFilePath = filePath;
        isDownloading = false;
      });

      await _uploadToWordPress(File(filePath));
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de téléchargement"), backgroundColor: Colors.red),
      );
    }
  }

  // fonction permet d'envoyer un fichier (image de la carte) vers un site WordPress en utilisant son API REST
  Future<void> _uploadToWordPress(File file) async {
    final url = Uri.parse("https://yourwordpresssite.com/wp-json/wp/v2/media");
    final request = http.MultipartRequest("POST", url);
    request.headers["Authorization"] = "Bearer YOUR_JWT_TOKEN";

    final mimeType = lookupMimeType(file.path);
    final multipartFile = await http.MultipartFile.fromPath(
      "file", file.path,
      contentType: mimeType != null ? MediaType.parse(mimeType) : MediaType("image", "png"),
    );
    request.files.add(multipartFile);

    final response = await request.send();
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Carte enregistrée sur WordPress !"), backgroundColor: Color(0xFF80C000)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Échec de l'upload"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Text(
            "Télécharger la carte",
            style: GoogleFonts.merriweather(
              color: Colors.white,
              fontSize: 20.0, // Ajustez la taille du texte ici
            ),
            textAlign: TextAlign.center, // Centrer le texte
          ),
        ),
        backgroundColor: Color(0xFF80C000),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isDownloading
                ? Column(
              children: [
                CircularProgressIndicator(value: downloadProgress, color: Color(0xFF80C000)),
                SizedBox(height: 16),
                Text("Téléchargement en cours...", style: GoogleFonts.merriweather(fontSize: 16)),
              ],
            )
                : Column(
              children: [
                Icon(Icons.cloud_download, size: 80, color: Color(0xFF80C000)),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _downloadAndUploadMap,
                  icon: Icon(Icons.download, color: Colors.white),
                  label: Text("Télécharger et enregistrer la carte"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF80C000),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: GoogleFonts.merriweather(fontSize: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OfflineMapPage()),
                    );
                  },
                  icon: Icon(Icons.map, color: Colors.white),
                  label: Text("Voir la carte téléchargée"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF80C000),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: GoogleFonts.merriweather(fontSize: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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


