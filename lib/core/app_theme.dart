// lib/core/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Colors ────────────────────────────────────────────────────────────────
  static const Color bg           = Color(0xFF0D0B1E);
  static const Color bgCard       = Color(0xFF13112A);
  static const Color bgSurface    = Color(0xFF1C1A36);
  static const Color accent       = Color(0xFF7F77DD);
  static const Color accentLight  = Color(0xFFAFA9EC);
  static const Color gold         = Color(0xFFEF9F27);
  static const Color teal         = Color(0xFF1D9E75);
  static const Color coral        = Color(0xFFD85A30);
  static const Color pink         = Color(0xFFD4537E);
  static const Color blue         = Color(0xFF378ADD);
  static const Color green        = Color(0xFF639922);
  static const Color textPrimary  = Color(0xFFFFFFFF);
  static const Color textSec      = Color(0x99FFFFFF);
  static const Color textMuted    = Color(0x55FFFFFF);
  static const Color border       = Color(0x22FFFFFF);

  // ─── Gradients ─────────────────────────────────────────────────────────────
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

  // ─── Material Theme ─────────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      secondary: gold,
      surface: bgCard,
      error: coral,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.exo2(
          fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary),
      headlineLarge: GoogleFonts.exo2(
          fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
      headlineMedium: GoogleFonts.exo2(
          fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w400, color: textPrimary),
      bodyMedium: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w400, color: textSec),
      bodySmall: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w400, color: textMuted),
      labelLarge: GoogleFonts.exo2(
          fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.exo2(
        fontSize: 18, fontWeight: FontWeight.w700,
        color: accent, letterSpacing: 1,
      ),
      iconTheme: const IconThemeData(color: accentLight),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(
            horizontal: 28, vertical: 14),
        textStyle: GoogleFonts.exo2(
            fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    cardColor: bgCard,
    dividerColor: border,
  );
}

// ─── App Constants ────────────────────────────────────────────────────────────
class AppConstants {
  static const String appName        = 'GameReel';
  static const String triviaApiBase  = 'https://opentdb.com/api.php';

  static const int xpPerPlay    = 20;
  static const int xpPerWin     = 100;

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
