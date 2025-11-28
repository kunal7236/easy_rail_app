import 'package:flutter/material.dart';

class AppTheme {
  // Your CSS Colors
  static const Color background = Color(0xFFF1F3F8);
  static const Color accent = Color(0xFFA1D6E2);
  static const Color accentDark = Color(0xFF0A043C);
  static const Color accentGreen = Color(0xFFC2F5BA);
  static const Color accentRed = Color(0xFFD74F4F);
  static const Color textPrimary = Color(0xFF161614);

  // Text Styles
  static const TextStyle logo = TextStyle(
    fontFamily: 'Lemonada',
    fontSize: 24.0,
    color: textPrimary,
  );

  static const TextStyle heading = TextStyle(
    fontFamily: 'Outfit',
    fontWeight: FontWeight.w500,
    fontSize: 22.0,
    decoration: TextDecoration.underline,
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w500,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Lexend',
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
  );

  // Main App Theme
  static ThemeData get theme {
    return ThemeData(
      primaryColor: accent,
      scaffoldBackgroundColor: background,
      fontFamily: 'Outfit',
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: logo,
        iconTheme: IconThemeData(color: textPrimary),
      ),

      // Styles your input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: accentDark, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: accentDark, width: 2.0),
        ),
      ),

      // Styles your buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: accentDark,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          side: const BorderSide(color: accentDark, width: 2.0),
        ),
      ),
    );
  }
}