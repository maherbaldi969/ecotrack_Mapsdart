import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Couleurs
const Color vertPrimaire = Color(0xFF80C000);
const Color blanc = Color(0xFFFFFFFF);
const Color noir = Color(0xFF000000);
const Color vertClair = Color(0xFFE8F5E9);
const Color vertFonce = Color(0xFF2E7D32);
const Color gris = Color(0xFF9E9E9E);

// Styles de texte
final TextStyle merriweatherBold = GoogleFonts.merriweather(
  fontWeight: FontWeight.bold,
  color: noir,
  fontSize: 16,
);

final TextStyle merriweatherNormal = GoogleFonts.merriweather(
  color: noir,
  fontSize: 14,
);

final TextStyle merriweatherTitre = GoogleFonts.merriweather(
  fontWeight: FontWeight.bold,
  color: blanc,
  fontSize: 20,
);

final TextStyle merriweatherSousTitre = GoogleFonts.merriweather(
  fontWeight: FontWeight.w600,
  color: noir,
  fontSize: 18,
);

final TextStyle merriweatherBouton = GoogleFonts.merriweather(
  fontWeight: FontWeight.bold,
  color: blanc,
  fontSize: 16,
  letterSpacing: 0.5,
);

// Styles de bouton
final ButtonStyle boutonVert = ElevatedButton.styleFrom(
  minimumSize: const Size.fromHeight(50),
  backgroundColor: vertPrimaire,
  foregroundColor: blanc,
  textStyle: merriweatherBouton,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  elevation: 4,
);

final ButtonStyle boutonVertOutlined = OutlinedButton.styleFrom(
  minimumSize: const Size.fromHeight(50),
  foregroundColor: vertPrimaire,
  textStyle: merriweatherBouton.copyWith(color: vertPrimaire),
  side: const BorderSide(color: vertPrimaire, width: 2),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
);

// Style de carte
final CardTheme cardTheme = CardTheme(
  elevation: 2,
  margin: EdgeInsets.zero,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  color: blanc,
);

// Style de champ de texte
final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
  filled: true,
  fillColor: vertClair.withOpacity(0.3),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide.none,
  ),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  hintStyle: merriweatherNormal.copyWith(color: gris),
  labelStyle: merriweatherNormal.copyWith(color: vertFonce),
);

// Thème global
final ThemeData appTheme = ThemeData(
  primaryColor: vertPrimaire,
  colorScheme: ColorScheme.light(
    primary: vertPrimaire,
    secondary: vertFonce,
    surface: blanc,
    background: vertClair,
  ),
  fontFamily: GoogleFonts.merriweather().fontFamily,
  cardTheme: cardTheme,
  inputDecorationTheme: inputDecorationTheme,
  appBarTheme: AppBarTheme(
    backgroundColor: vertPrimaire,
    foregroundColor: blanc,
    centerTitle: true,
    elevation: 0,
    titleTextStyle: merriweatherTitre,
    iconTheme: const IconThemeData(color: blanc),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(16),
      ),
    ),
  ),
);