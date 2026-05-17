// lib/core/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // ─── ScrollX Color Palette ──────────────────────────────────────────────────
  static const Color primary       = Color(0xFFE4D400); // Rich warm yellow
  static const Color consoleYellow = Color(0xFFFFD600); // Active button yellow
  static const Color yellowDark    = Color(0xFFB89800); // Solid shadow for yellow — no opacity
  static const Color yellowLight   = Color(0xFFFFEA64);
  static const Color primaryDark   = Color(0xFFD4A800);

  // White / surface
  static const Color bg          = Color(0xFFFFFFFF);
  static const Color bgWarm      = Color(0xFFFAF9F0); // Warm off-white
  static const Color bgCard      = Color(0xFFF5F5F0); // Slightly warm card surface
  static const Color bgSurface   = Color(0xFFEEEDE4); // Slightly darker surface
  static const Color navbarColor = Color(0xFFFFFFFF); // Navbar white
  static const Color navbarShadow= Color(0xFFD4D2C8); // Solid warm-grey shadow for navbar

  // Dark
  static const Color dark        = Color(0xFF1A1A1A);
  static const Color darkCard    = Color(0xFF2A2A2A);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSec     = Color(0xFF666666);
  static const Color textMuted   = Color(0xFF999999);
  static const Color border      = Color(0xFFE8E8E8);
  static const Color borderWarm  = Color(0xFFDDDBC8);

  // ─── SOLID-COLOR HARD SHADOWS — zero opacity, zero blur ────────────────────
  // Rule: every shadow is a solid darker shade of its parent. No rgba. No alpha.

  /// Yellow button shadow — dark mustard, no opacity
  static const BoxShadow yellowButtonShadow = BoxShadow(
    color: Color(0xFFB89800), // solid dark mustard
    blurRadius: 0,
    spreadRadius: 0,
    offset: Offset(0, 5),
  );

  /// Card / pill shadow — slightly darker warm surface, no opacity
  static const BoxShadow hardShadowSmall = BoxShadow(
    color: Color(0xFFCCCBC0), // solid warm grey
    blurRadius: 0,
    spreadRadius: 0,
    offset: Offset(0, 3),
  );

  /// General card shadow
  static const BoxShadow hardShadow = BoxShadow(
    color: Color(0xFFBBBAB0), // solid warm grey, slightly darker
    blurRadius: 0,
    spreadRadius: 0,
    offset: Offset(0, 4),
  );

  /// Navbar shadow — strongest in the app, solid warm grey
  static const BoxShadow hardShadowStrong = BoxShadow(
    color: Color(0xFFB8B6AA), // solid warm grey dock shadow
    blurRadius: 0,
    spreadRadius: 0,
    offset: Offset(0, 8),
  );

  // ─── Keep game-specific colors ──────────────────────────────────────────────
  static const Color accent      = Color(0xFF7F77DD);
  static const Color accentLight = Color(0xFFAFA9EC);
  static const Color gold        = Color(0xFFF5C800);
  static const Color teal        = Color(0xFF1D9E75);
  static const Color coral       = Color(0xFFD85A30);
  static const Color pink        = Color(0xFFD4537E);
  static const Color blue        = Color(0xFF378ADD);
  static const Color green       = Color(0xFF639922);

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
    fontFamily: 'National Park',
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: dark,
      surface: bgCard,
      error: coral,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w800, color: textPrimary),
      headlineLarge: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
      headlineMedium: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary),
      bodyMedium: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w400, color: textSec),
      bodySmall: TextStyle(
          fontSize: 10, fontWeight: FontWeight.w400, color: textMuted),
      labelLarge: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 17, fontWeight: FontWeight.w700,
        color: dark, letterSpacing: 0,
      ),
      iconTheme: IconThemeData(color: dark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: dark,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        textStyle: const TextStyle(
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
