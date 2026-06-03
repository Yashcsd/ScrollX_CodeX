// lib/services/haptics_service.dart
import 'dart:async';
import 'package:flutter/services.dart';

class HapticsService {
  HapticsService._();

  /// Soft light vibration for general tap down, button release, tab switch
  static Future<void> light() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Medium vibration for success feedback, correct answers, puzzle tile moves
  static Future<void> medium() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Heavy vibration for major achievements, wins, level-ups, badge unlocks
  static Future<void> heavy() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Tick selection vibration for scroll wheels and feed swiping
  static Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Countdown haptic behavior.
  /// Final 5 seconds: rhythmic soft pulse.
  /// Final 3 seconds: slightly intensified pulse.
  /// At 0: heavy pulse.
  static Future<void> timerTick(int secondsRemaining) async {
    if (secondsRemaining <= 0) {
      await heavy();
    } else if (secondsRemaining <= 3) {
      await medium();
    } else if (secondsRemaining <= 5) {
      await light();
    }
  }

  /// High-satisfaction success pattern
  static Future<void> successSequence() async {
    try {
      await medium();
      await Future.delayed(const Duration(milliseconds: 80));
      await heavy();
    } catch (_) {}
  }

  /// Gentle dual failure warning pattern
  static Future<void> failureSequence() async {
    try {
      await light();
      await Future.delayed(const Duration(milliseconds: 120));
      await light();
    } catch (_) {}
  }
}
