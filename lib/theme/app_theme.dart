import 'package:flutter/material.dart';

class AppTheme {
  // Identidad principal
  static const Color primaryRed = Color(0xFFB71C1C);
  static const Color darkRed = Color(0xFF8E0000);

  // Colores secundarios
  static const Color navyBlue = Color(0xFF17324D);
  static const Color blue = Color(0xFF245B7A);

  // Fondos
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;

  // Textos
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF64748B);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRed,
        brightness: Brightness.light,
        primary: primaryRed,
        secondary: navyBlue,
        surface: surface,
      ),

      scaffoldBackgroundColor: background,

      appBarTheme: const AppBarTheme(
        backgroundColor: navyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shadowColor: Colors.black12,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD9E0E7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD9E0E7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
      ),
    );
  }
}
