// lib/services/user_provider.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/score_model.dart';
import '../models/user_model.dart';
import '../core/app_theme.dart';
import 'firestore_service.dart';
import 'session_manager.dart';

class UserProvider extends ChangeNotifier {
  final _uuid      = const Uuid();
  final _firestore = FirestoreService();

  UserModel? _user;
  bool       _loading       = true;
  bool       _sessionActive = false;
  String?    _error;

  UserModel? get user        => _user;
  bool       get isLoading   => _loading;
  String?    get error       => _error;

  /// Single gate: true only when session_v2 is set AND profile loaded
  bool get isLoggedIn => _sessionActive && _user != null;

  Stream<List<UserModel>> leaderboardStream() =>
      _firestore.leaderboardStream();

  // ── initialize ────────────────────────────────────────────────────────────
  Future<void> initialize() async {
    _loading = true;
    notifyListeners();

    try {
      _sessionActive = await SessionManager.isSessionActive();

      if (_sessionActive) {
        final prefs   = await SharedPreferences.getInstance();
        final savedId = prefs.getString('user_id');

        if (savedId != null && savedId.isNotEmpty) {
          _user = UserModel(
            id:             savedId,
            username:       prefs.getString('username')       ?? 'Player',
            avatarInitials: prefs.getString('avatarInitials') ?? 'PL',
            totalXp:        prefs.getInt('totalXp')           ?? 0,
            gamesWon:       prefs.getInt('gamesWon')          ?? 0,
            gamesPlayed:    prefs.getInt('gamesPlayed')       ?? 0,
            bestScores:     _parseBestScores(
                prefs.getString('bestScores') ?? ''),
            badges:         _parseBadges(
                prefs.getString('badges') ?? ''),
          );
          unawaited(_syncUserToFirestore(_user!));
        } else {
          // session flag set but no profile — reset to onboarding
          _sessionActive = false;
          await SessionManager.clearSession();
        }
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('UserProvider.initialize error: $e');
    }

    _loading = false;
    notifyListeners();
  }

  // ── createUser ────────────────────────────────────────────────────────────
  Future<void> createUser(String username) async {
    if (username.trim().isEmpty) return;
    _loading = true;
    _error   = null;
    notifyListeners();

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final id = firebaseUser?.uid ?? _uuid.v4();

      final name     = username.trim();
      final initials = name.length >= 2
          ? name.substring(0, 2).toUpperCase()
          : name.toUpperCase();

      _user = UserModel(id: id, username: name, avatarInitials: initials);

      await _persistProfile(_user!);
      await SessionManager.markSessionActive();
      _sessionActive = true;

      unawaited(_syncUserToFirestore(_user!));
    } catch (e) {
      _error = e.toString();
      debugPrint('UserProvider.createUser error: $e');
    }

    _loading = false;
    notifyListeners();
  }

  // ── updateProfile ─────────────────────────────────────────────────────────
  Future<void> updateProfile(String newUsername) async {
    if (_user == null || newUsername.trim().isEmpty) return;

    final name     = newUsername.trim();
    final initials = name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();

    _user = _user!.copyWith(username: name, avatarInitials: initials);
    await _persistProfile(_user!);
    unawaited(_syncUserToFirestore(_user!));
    notifyListeners();
  }

  // ── recordGameResult ──────────────────────────────────────────────────────
  Future<void> recordGameResult({
    required String gameId,
    required String gameName,
    required int    score,
    required int    timeTakenSeconds,
    required bool   won,
  }) async {
    if (_user == null) return;

    int newXp     = _user!.totalXp    + AppConstants.xpPerPlay;
    int newWins   = _user!.gamesWon;
    int newPlayed = _user!.gamesPlayed + 1;
    final newBest = Map<String, int>.from(_user!.bestScores);
    final badges  = List<String>.from(_user!.badges);

    if (won) {
      newXp   += AppConstants.xpPerWin;
      newWins += 1;
    }

    if (!newBest.containsKey(gameId) || newBest[gameId]! < score) {
      newBest[gameId] = score;
    }

    void give(String b) { if (!badges.contains(b)) badges.add(b); }
    if (newPlayed == 1)                           give('First Game 🎮');
    if (newWins  >= 5)                            give('5 Wins 🏅');
    if (newWins  >= 10)                           give('10 Wins 🏆');
    if (newXp   >= 500)                           give('500 XP ⚡');
    if (newXp   >= 1000)                          give('1K XP 💎');
    if (gameId == 'slide_puzzle' && score >= 600) give('Puzzle Pro 🧩');
    if (gameId == 'trivia_quiz'  && score >= 500) give('Quiz Ace 🎯');
    if (gameId == 'memory_match' && score >= 500) give('Memory King 🃏');
    if (gameId == 'color_match'  && score >= 400) give('Color Master 🎨');

    _user = _user!.copyWith(
      totalXp:     newXp,
      gamesWon:    newWins,
      gamesPlayed: newPlayed,
      bestScores:  newBest,
      badges:      badges,
    );

    await _persistProfile(_user!);
    unawaited(_syncUserToFirestore(_user!));
    unawaited(_saveScoreToFirestore(
      gameId: gameId, gameName: gameName,
      score: score, timeTakenSeconds: timeTakenSeconds,
    ));
    notifyListeners();
  }

  // ── deleteAccount ─────────────────────────────────────────────────────────
  Future<void> deleteAccount() async {
    final deletedId = _user?.id;
    try {
      await SessionManager.clearSession();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (deletedId != null) await _firestore.deleteUser(deletedId);
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('UserProvider.deleteAccount error: $e');
    }
    _user          = null;
    _sessionActive = false;
    notifyListeners();
  }

  // ── private helpers ───────────────────────────────────────────────────────

  Future<void> _persistProfile(UserModel u) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id',       u.id);
    await prefs.setString('username',       u.username);
    await prefs.setString('avatarInitials', u.avatarInitials);
    await prefs.setInt('totalXp',           u.totalXp);
    await prefs.setInt('gamesWon',          u.gamesWon);
    await prefs.setInt('gamesPlayed',       u.gamesPlayed);
    await prefs.setString('bestScores',
        u.bestScores.entries.map((e) => '${e.key}:${e.value}').join(','));
    await prefs.setString('badges', u.badges.join('|'));
  }

  Map<String, int> _parseBestScores(String raw) {
    if (raw.isEmpty) return {};
    final result = <String, int>{};
    for (final part in raw.split(',')) {
      final kv = part.split(':');
      if (kv.length == 2) result[kv[0]] = int.tryParse(kv[1]) ?? 0;
    }
    return result;
  }

  List<String> _parseBadges(String raw) =>
      raw.isEmpty ? [] : raw.split('|').where((s) => s.isNotEmpty).toList();

  Future<void> _syncUserToFirestore(UserModel user) async {
    try {
      await _firestore.createUser(user);
    } catch (e) {
      debugPrint('UserProvider._syncUserToFirestore error: $e');
    }
  }

  Future<void> _saveScoreToFirestore({
    required String gameId,
    required String gameName,
    required int    score,
    required int    timeTakenSeconds,
  }) async {
    final u = _user;
    if (u == null) return;
    try {
      await _firestore.saveScore(ScoreModel(
        id: '', userId: u.id, username: u.username,
        gameId: gameId, gameName: gameName,
        score: score, timeTakenSeconds: timeTakenSeconds,
      ));
    } catch (e) {
      debugPrint('UserProvider._saveScoreToFirestore error: $e');
    }
  }
}
