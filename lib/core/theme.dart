import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF003B73), // A deep, professional navy blue
        brightness: Brightness.light,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0, 
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.black),
        headlineMedium: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.black87),
        headlineSmall: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.black87),
        titleLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.black),
        titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.black87),
        bodyLarge: GoogleFonts.inter(fontSize: 16, height: 1.6, color: Colors.black87),
        bodyMedium: GoogleFonts.inter(fontSize: 14, height: 1.5, color: Colors.black54),
        bodySmall: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEEEEE),
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF003B73),
        brightness: Brightness.dark,
        surface: const Color(0xFF121212),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.white),
        headlineMedium: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.white),
        headlineSmall: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.white),
        titleLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.white),
        titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white70),
        bodyLarge: GoogleFonts.inter(fontSize: 16, height: 1.6, color: Colors.white70),
        bodyMedium: GoogleFonts.inter(fontSize: 14, height: 1.5, color: Colors.white54),
        bodySmall: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2C2C2C),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
