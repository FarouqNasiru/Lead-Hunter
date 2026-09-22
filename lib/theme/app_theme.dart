import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand colors ──────────────────────────────────────────
  static const Color bg = Color(0xFF080C08); // near-black with green tint
  static const Color bgCard = Color(0xFF0F160F); // card surface
  static const Color bgInput = Color(0xFF141C14); // input field bg
  static const Color borderDim = Color(0xFF1E2B1E); // subtle borders
  static const Color borderActive = Color(0xFF2ECC71); // green border on focus

  static const Color green = Color(0xFF2ECC71); // primary accent
  static const Color greenDim = Color(0xFF1A7A44); // muted green
  static const Color greenGlow = Color(0x332ECC71); // glow overlay

  static const Color textPrimary = Color(
    0xFFECF5EC,
  ); // near-white with green tint
  static const Color textSecondary = Color(0xFF7A9B7A); // muted green-grey
  static const Color textHint = Color(0xFF3D5C3D); // placeholder text

  static const Color error = Color(0xFFFF5252);

  // ── Typography ────────────────────────────────────────────
  static TextTheme get _textTheme => TextTheme(
    // Display — sharp, technical feel
    displayLarge: GoogleFonts.spaceMono(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.spaceMono(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: -0.3,
    ),
    // Headlines — clean sans
    headlineLarge: GoogleFonts.dmSans(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    headlineMedium: GoogleFonts.dmSans(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    // Body
    bodyLarge: GoogleFonts.dmSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textSecondary,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.dmSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: textSecondary,
    ),
    // Labels
    labelLarge: GoogleFonts.dmSans(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      letterSpacing: 0.3,
    ),
    labelMedium: GoogleFonts.spaceMono(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: textSecondary,
      letterSpacing: 1.2,
    ),
  );

  // ── Full theme ────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: green,
      secondary: greenDim,
      surface: bgCard,
      background: bg,
      error: error,
      onPrimary: Color(0xFF080C08),
      onSurface: textPrimary,
    ),
    textTheme: _textTheme,

    // Input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgInput,
      hintStyle: GoogleFonts.dmSans(
        color: textHint,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderDim, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderDim, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderActive, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
    ),

    // Elevated button = primary CTA
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: green,
        foregroundColor: const Color(0xFF080C08),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        elevation: 0,
      ),
    ),

    // Text button = secondary action
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: green,
        textStyle: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    dividerTheme: const DividerThemeData(color: borderDim, thickness: 1),
    useMaterial3: true,
  );
}
