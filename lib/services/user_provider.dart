// lib/services/user_provider.dart
// 100% offline — uses SharedPreferences only.
// No Firebase import here. Add Firebase later in firestore_service.dart.
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../core/app_theme.dart';

class UserProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  UserModel? _user;
  bool       _loading = false;
  String?    _error;

  UserModel? get user       => _user;
  bool       get isLoading  => _loading;
  String?    get error      => _error;
  bool       get isLoggedIn => _user != null;

  // ─────────────────────────────────────────────────────────────────────────
  // READ: Boot app — load saved user from device storage
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> initialize() async {
    _loading = true;
    notifyListeners();

    try {
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
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('UserProvider.initialize error: $e');
    }

    _loading = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CREATE: register a brand-new user
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> createUser(String username) async {
    if (username.trim().isEmpty) return;
    _loading = true;
    _error   = null;
    notifyListeners();

    try {
      final id = _uuid.v4();
      final initials = username.trim().length >= 2
          ? username.trim().substring(0, 2).toUpperCase()
          : username.trim().toUpperCase();

      _user = UserModel(
          id: id,
          username: username.trim(),
          avatarInitials: initials);

      await _persist(_user!);
    } catch (e) {
      _error = e.toString();
      debugPrint('UserProvider.createUser error: $e');
    }

    _loading = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UPDATE: change username
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> updateProfile(String newUsername) async {
    if (_user == null || newUsername.trim().isEmpty) return;

    final initials = newUsername.trim().length >= 2
        ? newUsername.trim().substring(0, 2).toUpperCase()
        : newUsername.trim().toUpperCase();

    _user = _user!.copyWith(
        username: newUsername.trim(), avatarInitials: initials);
    await _persist(_user!);
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UPDATE: called after every game session
  // ─────────────────────────────────────────────────────────────────────────
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

    // Update best score for this game
    if (!newBest.containsKey(gameId) || newBest[gameId]! < score) {
      newBest[gameId] = score;
    }

    // Unlock badges
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
      totalXp:    newXp,
      gamesWon:   newWins,
      gamesPlayed: newPlayed,
      bestScores: newBest,
      badges:     badges,
    );

    await _persist(_user!);
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DELETE: wipe everything from device
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> deleteAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      debugPrint('UserProvider.deleteAccount error: $e');
    }
    _user = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Internal helpers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _persist(UserModel u) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id',       u.id);
    await prefs.setString('username',       u.username);
    await prefs.setString('avatarInitials', u.avatarInitials);
    await prefs.setInt('totalXp',           u.totalXp);
    await prefs.setInt('gamesWon',          u.gamesWon);
    await prefs.setInt('gamesPlayed',       u.gamesPlayed);
    // Encode Map<String,int> as "key1:100,key2:200"
    await prefs.setString('bestScores',
        u.bestScores.entries.map((e) => '${e.key}:${e.value}').join(','));
    // Encode badges as pipe-separated
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
}
