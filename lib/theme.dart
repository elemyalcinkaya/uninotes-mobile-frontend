import 'package:flutter/material.dart';

ThemeData buildTheme() {
  const primary = Color(0xFF7C3AED); // purple-600
  const primaryDark = Color(0xFF6D28D9); // purple-700
  const primaryLight = Color(0xFFEDE9FE); // purple-50

  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: primary,
      secondary: primaryDark,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSurface: const Color(0xFF111827),
    ),
    scaffoldBackgroundColor: const Color(0xFFF9FAFB), // gray-50
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    chipTheme: const ChipThemeData(
      color: MaterialStatePropertyAll(primaryLight),
      labelStyle: TextStyle(color: primaryDark, fontWeight: FontWeight.w600),
      side: BorderSide(color: Color(0xFFE5E7EB)),
      selectedColor: primaryLight,
    ),
  );
}

