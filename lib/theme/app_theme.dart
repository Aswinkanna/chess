import 'package:flutter/material.dart';

class AppTheme {
  // Purple-first brand palette
  static const Color seed = Color(0xFF6A1B9A);
  static const Color surface = Color(0xFF0F0A1A);
  static const Color boardDark = Color(0xFF2A1F3C);
  static const Color boardLight = Color(0xFFB08CFF);
  static const Color accent = Color(0xFFB388FF);
  static const Color chip = Color(0xFF2E2144);

  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      surface: surface,
      primary: seed,
      secondary: accent,
    ),
    scaffoldBackgroundColor: surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1027),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardColor: const Color(0xFF1E1330),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: seed,
        foregroundColor: Colors.white,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: chip,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white54),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: chip,
      labelStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
      headlineMedium: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
      titleLarge: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white70),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );
}
