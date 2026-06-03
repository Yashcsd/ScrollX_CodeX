import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../core/app_theme.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'profile_service.dart';
import 'session_manager.dart';
import 'supabase_service.dart';

class UserProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  UserModel? _user;
  bool _loading = true;
  bool _sessionActive = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _loading;
  String? get error => _error;

  bool get isLoggedIn => _sessionActive && _user != null;

  Stream<List<UserModel>> leaderboardStream() {
    return ProfileService.leaderboardStream();
  }

  Future<UserModel?> ensureAuthenticatedUser() async {
    if (_user != null && SupabaseService.isSignedIn) return _user;

    try {
      final response = await AuthService.signInAsGuest(data: {
        'username': _user?.username ?? 'Player',
      });
      final id = response.user?.id;
      if (id == null) return _user;

      final current = _user ?? _localGuest(name: 'Player', id: id);
      _user = current.copyWith(id: id);
      await ProfileService.upsertProfile(_user!);
      await _persistProfile(_user!);
      await SessionManager.markSessionActive();
      _sessionActive = true;
      notifyListeners();
    } catch (e) {
      debugPrint('UserProvider.ensureAuthenticatedUser error: $e');
    }
    return _user;
  }

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();

    try {
      final authUser = SupabaseService.client.auth.currentUser;
      if (authUser != null) {
        _user = await ProfileService.getProfile(authUser.id);
        if (_user == null) {
          _user = _localGuest(name: _nameFromAuth(authUser), id: authUser.id);
          await ProfileService.upsertProfile(_user!);
        }
        await _persistProfile(_user!);
        await SessionManager.markSessionActive();
        _sessionActive = true;
      } else {
        await _loadLocalSession();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('UserProvider.initialize error: $e');
      await _loadLocalSession();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> createUser(String username) async {
    if (username.trim().isEmpty) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final name = username.trim();
      _user = _localGuest(name: name, id: SupabaseService.userId ?? _uuid.v4());
      await _persistProfile(_user!);
      await SessionManager.markSessionActive();
      _sessionActive = true;

      if (!SupabaseService.isSignedIn) {
        final response = await AuthService.signInAsGuest(data: {'username': name});
        final remoteId = response.user?.id;
        if (remoteId != null) {
          _user = _user!.copyWith(id: remoteId);
          await _persistProfile(_user!);
        }
      }

      if (SupabaseService.isSignedIn) {
        _user = await ProfileService.upsertProfile(_user!);
        await _persistProfile(_user!);
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('UserProvider.createUser error: $e');
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> updateProfile(String newUsername) async {
    if (_user == null || newUsername.trim().isEmpty) return;

    final name = newUsername.trim();
    final initials =
        name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();

    _user = _user!.copyWith(username: name, avatarInitials: initials);
    await _persistProfile(_user!);

    if (SupabaseService.isSignedIn) {
      try {
        await ProfileService.updateProfile(_user!);
      } catch (e) {
        debugPrint('UserProvider.updateProfile remote error: $e');
      }
    }
    notifyListeners();
  }

  Future<void> recordGameResult({
    required String gameId,
    required String gameName,
    required int score,
    required int timeTakenSeconds,
    required bool won,
  }) async {
    if (_user == null) return;

    int newXp = _user!.totalXp + AppConstants.xpPerPlay;
    int newWins = _user!.gamesWon;
    int newPlayed = _user!.gamesPlayed + 1;
    final newBest = Map<String, int>.from(_user!.bestScores);
    final badges = List<String>.from(_user!.badges);

    if (won) {
      newXp += AppConstants.xpPerWin;
      newWins += 1;
    }

    if (!newBest.containsKey(gameId) || newBest[gameId]! < score) {
      newBest[gameId] = score;
    }

    void give(String badge) {
      if (!badges.contains(badge)) badges.add(badge);
    }

    if (newPlayed == 1) give('First Game');
    if (newWins >= 5) give('5 Wins');
    if (newWins >= 10) give('10 Wins');
    if (newXp >= 500) give('500 XP');
    if (newXp >= 1000) give('1K XP');
    if (gameId == 'slide_puzzle' && score >= 600) give('Puzzle Pro');
    if (gameId == 'trivia_quiz' && score >= 500) give('Quiz Ace');
    if (gameId == 'memory_match' && score >= 500) give('Memory King');
    if (gameId == 'color_match' && score >= 400) give('Color Master');

    _user = _user!.copyWith(
      totalXp: newXp,
      gamesWon: newWins,
      gamesPlayed: newPlayed,
      bestScores: newBest,
      badges: badges,
    );

    await _persistProfile(_user!);
    if (SupabaseService.isSignedIn) {
      try {
        await ProfileService.updateProfile(_user!);
      } catch (e) {
        debugPrint('UserProvider.recordGameResult remote error: $e');
      }
    }
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    try {
      await AuthService.signOut();
    } catch (e) {
      debugPrint('UserProvider.deleteAccount remote error: $e');
    }

    try {
      await SessionManager.clearSession();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _user = null;
      _sessionActive = false;
      notifyListeners();
    } catch (e) {
      debugPrint('UserProvider.deleteAccount local error: $e');
    }
  }

  UserModel _localGuest({required String name, required String id}) {
    final initials =
        name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
    return UserModel(id: id, username: name, avatarInitials: initials);
  }

  String _nameFromAuth(User user) {
    final metadataName = user.userMetadata?['username'] ?? user.userMetadata?['name'];
    return metadataName?.toString() ?? user.email?.split('@').first ?? 'Player';
  }

  Future<void> _loadLocalSession() async {
    _sessionActive = await SessionManager.isSessionActive();
    if (!_sessionActive) return;

    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('user_id');
    if (savedId == null || savedId.isEmpty) {
      _sessionActive = false;
      await SessionManager.clearSession();
      return;
    }

    _user = UserModel(
      id: savedId,
      username: prefs.getString('username') ?? 'Player',
      avatarInitials: prefs.getString('avatarInitials') ?? 'PL',
      totalXp: prefs.getInt('totalXp') ?? 0,
      gamesWon: prefs.getInt('gamesWon') ?? 0,
      gamesPlayed: prefs.getInt('gamesPlayed') ?? 0,
      bestScores: _parseBestScores(prefs.getString('bestScores') ?? ''),
      badges: _parseBadges(prefs.getString('badges') ?? ''),
    );
  }

  Future<void> _persistProfile(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('username', user.username);
    await prefs.setString('avatarInitials', user.avatarInitials);
    await prefs.setInt('totalXp', user.totalXp);
    await prefs.setInt('gamesWon', user.gamesWon);
    await prefs.setInt('gamesPlayed', user.gamesPlayed);
    await prefs.setString(
      'bestScores',
      user.bestScores.entries.map((entry) => '${entry.key}:${entry.value}').join(','),
    );
    await prefs.setString('badges', user.badges.join('|'));
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
