// lib/core/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── New ScrollX Color Palette ──────────────────────────────────────────────
  static const Color primary     = Color(0xFFF5C800); // Yellow
  static const Color primaryDark = Color(0xFFD4A800); // Darker yellow
  static const Color bg          = Color(0xFFFFFFFF); // White background
  static const Color bgCard      = Color(0xFFF8F8F8); // Light card
  static const Color bgSurface   = Color(0xFFF0F0F0); // Surface
  static const Color dark        = Color(0xFF1A1A1A); // Near black
  static const Color darkCard    = Color(0xFF2A2A2A); // Dark card
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSec     = Color(0xFF666666);
  static const Color textMuted   = Color(0xFF999999);
  static const Color border      = Color(0xFFE8E8E8);

  // ─── Keep game-specific colors ──────────────────────────────────────────────
  static const Color accent      = Color(0xFF7F77DD);
  static const Color accentLight = Color(0xFFAFA9EC);
  static const Color gold        = Color(0xFFF5C800);
  static const Color yellow      = Color(0xFFE4D400); // Alias for primary yellow
  static const Color teal        = Color(0xFF1D9E75);
  static const Color coral       = Color(0xFFD85A30);
  static const Color pink        = Color(0xFFD4537E);
  static const Color blue        = Color(0xFF378ADD);
  static const Color green       = Color(0xFF639922);
  static const Color textDark    = Color(0xFF1A1A1A); // Alias for dark text

  // ─── Game gradients (unchanged) ─────────────────────────────────────────────
  static const LinearGradient puzzleGrad = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF16213E), Color(0xFF0F3460)],
  );
  static const LinearGradient triviaGrad = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF1A0533), Color(0xFF4A0D7C)],
  );
  static const LinearGradient memoryGrad = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF0A2E1A), Color(0xFF0F5E3A)],
  );
  static const LinearGradient colorGrad = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF2E0A0A), Color(0xFF7A1A1A)],
  );

  // ─── Material Theme ──────────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: bg,
    fontFamily: GoogleFonts.manrope().fontFamily,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: dark,
      surface: bgCard,
      error: coral,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.manrope(
          fontSize: 28, fontWeight: FontWeight.w800, color: textPrimary),
      headlineLarge: GoogleFonts.manrope(
          fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
      headlineMedium: GoogleFonts.manrope(
          fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge: GoogleFonts.manrope(
          fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary),
      bodyMedium: GoogleFonts.manrope(
          fontSize: 12, fontWeight: FontWeight.w400, color: textSec),
      bodySmall: GoogleFonts.manrope(
          fontSize: 10, fontWeight: FontWeight.w400, color: textMuted),
      labelLarge: GoogleFonts.manrope(
          fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.manrope(
        fontSize: 17, fontWeight: FontWeight.w700,
        color: dark, letterSpacing: 0,
      ),
      iconTheme: const IconThemeData(color: dark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: dark,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        textStyle: GoogleFonts.manrope(
            fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),
    cardColor: bgCard,
    dividerColor: border,
  );
}

// ─── App Constants ────────────────────────────────────────────────────────────
class AppConstants {
  static const String appName       = 'ScrollX';
  static const String triviaApiBase = 'https://opentdb.com/api.php';

  static const int xpPerPlay = 20;
  static const int xpPerWin  = 100;

  static const List<String> levels = [
    'Newcomer','Rookie','Player','Challenger',
    'Expert','Master','Grandmaster','Legend',
    'Mythic','Puzzle God',
  ];

  static String  levelTitle(int xp) =>
      levels[(xp ~/ 500).clamp(0, levels.length - 1)];

  static int     levelNumber(int xp) => (xp ~/ 500) + 1;

  static double  xpProgress(int xp)  => (xp % 500) / 500.0;
}
