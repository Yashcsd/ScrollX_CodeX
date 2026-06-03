// lib/services/audio_service.dart
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  AudioService._();

  static final AudioPlayer _musicPlayer = AudioPlayer();
  
  static const String _keyMuted = 'audio_muted';
  static const String _keyMusicVol = 'audio_music_vol';
  static const String _keySfxVol = 'audio_sfx_vol';

  static bool _isMuted = false;
  static double _musicVolume = 0.4;
  static double _sfxVolume = 0.5;
  static String? _currentMusic;

  static bool get isMuted => _isMuted;
  static double get musicVolume => _musicVolume;
  static double get sfxVolume => _sfxVolume;

  /// Load preferences and initialize volume states
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMuted = prefs.getBool(_keyMuted) ?? false;
      _musicVolume = prefs.getDouble(_keyMusicVol) ?? 0.4;
      _sfxVolume = prefs.getDouble(_keySfxVol) ?? 0.5;
      
      await _applyVolumes();
    } catch (e) {
      debugPrint("AudioService init error: $e");
    }
  }

  static Future<void> _applyVolumes() async {
    try {
      await _musicPlayer.setVolume(_isMuted ? 0.0 : _musicVolume);
    } catch (_) {}
  }

  /// Toggle global mute state
  static Future<void> toggleMute(bool mute) async {
    _isMuted = mute;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMuted, mute);
    await _applyVolumes();
  }

  /// Update music volume slider value
  static Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyMusicVol, _musicVolume);
    await _applyVolumes();
  }

  /// Update SFX volume slider value
  static Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keySfxVol, _sfxVolume);
  }

  /// Play background music loop for a specific category
  static Future<void> playMusic(String category) async {
    if (_currentMusic == category) return;
    _currentMusic = category;

    try {
      await _musicPlayer.stop();
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(_isMuted ? 0.0 : _musicVolume);
      await _musicPlayer.play(AssetSource('audio/${category}_loop.wav'));
    } catch (e) {
      debugPrint("Error playing music loop: $e");
    }
  }

  /// Stop background music loop with a smooth volume fade-out
  static Future<void> stopMusic({int fadeDurationMs = 500}) async {
    _currentMusic = null;
    final double startVol = _isMuted ? 0.0 : _musicVolume;
    if (startVol == 0.0) {
      try {
        await _musicPlayer.stop();
      } catch (_) {}
      return;
    }

    const steps = 8;
    final stepTime = fadeDurationMs ~/ steps;
    for (int i = 0; i <= steps; i++) {
      final double vol = startVol * (1.0 - i / steps);
      try {
        await _musicPlayer.setVolume(vol);
      } catch (_) {}
      await Future.delayed(Duration(milliseconds: stepTime));
    }

    try {
      await _musicPlayer.stop();
    } catch (_) {}
  }

  /// Play a one-shot sound effect. Instantiates a self-disposing player to support overlapping sounds.
  static Future<void> playSfx(String sfxName) async {
    if (_isMuted) return;
    try {
      final player = AudioPlayer();
      await player.setVolume(_sfxVolume);
      await player.play(AssetSource('audio/$sfxName.wav'));
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (e) {
      debugPrint("Error playing SFX $sfxName: $e");
    }
  }
}
