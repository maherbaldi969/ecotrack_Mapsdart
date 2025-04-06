import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({super.key});

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  File? _media;
  VideoPlayerController? _videoController;
  final ImagePicker _picker = ImagePicker();
  bool isVideo = false;
  String shareText = "🌍 Découvrez cette magnifique randonnée ! #EcoTrack #Aventure #Nature";
  //final List<Map<String, String>> _pendingShares = []; // File d'attente pour les partages hors ligne

  @override
  void initState() {
    super.initState();
    _checkPendingShares(); // Vérifier les partages en attente au démarrage
  }

  Future<void> _pickMedia(ImageSource source, {bool video = false}) async {
    final XFile? file = video
        ? await _picker.pickVideo(source: source)
        : await _picker.pickImage(source: source);

    if (file != null) {
      setState(() {
        _media = File(file.path);
        isVideo = video;
      });

      if (isVideo) {
        _videoController?.dispose();
        _videoController = VideoPlayerController.file(_media!)
          ..initialize().then((_) {
            setState(() {});
            _videoController!.play();
          });
      }
    }
  }

  Future<void> _saveToGallery() async {
    if (_media != null) {
      try {
        String fileName = "media_${DateTime.now().millisecondsSinceEpoch}.${isVideo ? "mp4" : "jpg"}";

        final result = await SaverGallery.saveFile(
          filePath: _media!.path,
          fileName: fileName,
          androidRelativePath: "Pictures/EcoTrack",
          skipIfExists: false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.isSuccess ? "Média enregistré avec succès !" : "Échec de l'enregistrement"),
          ),
        );
      } catch (e) {
        print("Erreur d'enregistrement : $e");
      }
    }
  }

  Future<void> _shareMedia() async {
    if (_media != null) {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Stocker le partage en attente si hors ligne
        await _savePendingShare(_media!.path, shareText);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucune connexion Internet. Le partage sera effectué plus tard.")),
        );
        return;
      }
      await Share.shareXFiles([XFile(_media!.path)], text: shareText); // Associer le texte personnalisé au média
    }
  }

  Future<void> _savePendingShare(String filePath, String text) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingShares = prefs.getStringList('pendingShares') ?? [];
    pendingShares.add('$filePath|$text');
    await prefs.setStringList('pendingShares', pendingShares);
  }

  Future<void> _checkPendingShares() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingShares = prefs.getStringList('pendingShares') ?? [];

    if (pendingShares.isNotEmpty) {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        for (var share in pendingShares) {
          final parts = share.split('|');
          final filePath = parts[0];
          final text = parts[1];
          await Share.shareXFiles([XFile(filePath)], text: text); // Associer le texte personnalisé au média
        }
        await prefs.remove('pendingShares'); // Supprimer les partages en attente après traitement
      }
    }
  }

  Future<void> _editShareText() async {
    final textController = TextEditingController(text: shareText); // Contrôleur pour le champ de texte

    final newText = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Modifier le texte de partage"),
        content: TextField(
          controller: textController, // Utiliser le contrôleur
          decoration: const InputDecoration(hintText: "Entrez votre texte"),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, textController.text); // Récupérer le texte saisi
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );

    if (newText != null) {
      setState(() {
        shareText = newText; // Mettre à jour le texte de partage
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Capture Média", style: GoogleFonts.merriweather(fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: const Color(0xFF80C000),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded( // Utiliser Expanded pour occuper l'espace disponible
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _media == null
                    ? const Center(
                  child: Icon(Icons.camera_alt, size: 100, color: Colors.black54),
                )
                    : isVideo && _videoController != null && _videoController!.value.isInitialized
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(_media!, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1, offset: const Offset(0, 3)),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIconButton(Icons.photo_camera, "Photo", () => _pickMedia(ImageSource.camera)),
                _buildIconButton(Icons.videocam, "Vidéo", () => _pickMedia(ImageSource.camera, video: true)),
                _buildIconButton(Icons.save, "Enregistrer", _saveToGallery),
                _buildIconButton(Icons.share, "Partager", _shareMedia),
                _buildIconButton(Icons.edit, "Modifier", _editShareText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 30, color: const Color(0xFF80C000)),
        ),
        Text(label, style: GoogleFonts.merriweather(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black)),
      ],
    );
  }
}