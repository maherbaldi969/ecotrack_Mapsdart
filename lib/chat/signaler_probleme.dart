import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

class SignalerProblemePage extends StatefulWidget {
  @override
  _SignalerProblemePageState createState() => _SignalerProblemePageState();
}

class _SignalerProblemePageState extends State<SignalerProblemePage> {
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedProbleme;
  File? _image;

  final List<String> _problemes = [
    "Chemin bloqué",
    "Blessure",
    "Météo dangereuse",
    "Autre"
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black87 : Colors.white,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_outlined,
                    color: isDarkMode ? Colors.white : Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF80C000),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 48), // For alignment
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Type de problème:",
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: _selectedProbleme,
                  items: _problemes.map((String probleme) {
                    return DropdownMenuItem<String>(
                      value: probleme,
                      child: Text(probleme),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProbleme = value;
                    });
                  },
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
                SizedBox(height: 16),

                Text("Description:",
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Décrivez le problème...",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                ElevatedButton.icon(
                  icon: Icon(Icons.camera_alt),
                  label: Text(
                    "Ajouter une photo",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF80C000)),
                ),
                if (_image != null) Image.file(_image!, height: 100),

                SizedBox(height: 24),

                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Handle submission
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8B8787)),
                    child: Text(
                      "Envoyer le signalement",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
