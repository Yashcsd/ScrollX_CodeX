// lib/services/session_manager.dart
//
// Single source of truth for auth/session state.
// Versioned key — bump version to force re-onboarding on all installs.
//   session_v1 → old (no Google login)
//   session_v2 → current (with Google login)

import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  // ── bump this string to force all users through onboarding again ──────────
  static const _kSession = 'session_v2';

  static Future<bool> isSessionActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSession) ?? false;
  }

  static Future<void> markSessionActive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSession, true);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    // Clear ALL session keys (old + new) so nothing leaks
    await prefs.remove(_kSession);
    await prefs.remove('session_v1');
    await prefs.remove('onboarding_done');
  }
}
