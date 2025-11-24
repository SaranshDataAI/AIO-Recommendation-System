import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  /// Anime-vibrant dark theme with neon accents.
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF050816),
    useMaterial3: true,
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFF6FD8), // neon pink
      secondary: Color(0xFF00F5A0), // teal / mint
      surface: Color(0xFF050816),
    ),
  );
}
