import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/game_comment_model.dart';
import '../models/game_social_metadata.dart';
import '../models/game_social_model.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class GameSocialService {
  GameSocialService._();

  static final SupabaseClient _client = SupabaseService.client;

  // Anti-spam & rate limiting memory states
  static final Map<String, DateTime> _lastLikeTime = {};
  static final Map<String, DateTime> _lastCommentTime = {};
  static String? _lastCommentText;

  static Stream<GameSocialStats> statsStream(String gameId) {
    return _client
        .from('game_social_stats')
        .stream(primaryKey: ['game_id'])
        .map((rows) {
          final matches = rows.where((row) => row['game_id'] == gameId);
          if (matches.isEmpty) return const GameSocialStats();
          return GameSocialStats.fromMap(matches.first);
        });
  }

  static Stream<GameUserSocialState> userStateStream({
    required String gameId,
    required String? userId,
  }) {
    if (userId == null) return Stream.value(const GameUserSocialState());
    return _client
        .from('game_user_states')
        .stream(primaryKey: ['game_id', 'user_id'])
        .map((rows) {
          final matches = rows.where(
            (row) => row['game_id'] == gameId && row['user_id'] == userId,
          );
          if (matches.isEmpty) return const GameUserSocialState();
          return GameUserSocialState.fromMap(matches.first);
        });
  }

  static Stream<List<GameComment>> commentsStream(String gameId) {
    return _client
        .from('game_comments')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(100)
        .map(
          (rows) => rows
              .where((row) => row['game_id'] == gameId)
              .map(
                (row) => GameComment.fromMap(
                  row,
                  id: row['id'].toString(),
                ),
              )
              .toList(),
        );
  }

  static Future<void> seedStats({
    required GameSocialMetadata metadata,
  }) async {
    try {
      await _ensureGame(metadata);
    } catch (e) {
      debugPrint('GameSocialService.seedStats error: $e');
    }
  }

  static Future<void> recordPlay({
    required String gameId,
    required String? userId,
    required GameSocialMetadata metadata,
  }) async {
    try {
      await _ensureGame(metadata);
      await _client.from('game_plays').insert({
        'game_id': gameId,
        if (userId != null) 'user_id': userId,
      });
    } catch (e) {
      debugPrint('GameSocialService.recordPlay error: $e');
    }
  }

  static Future<void> toggleLike({
    required String gameId,
    required String? userId,
    required GameSocialMetadata metadata,
  }) async {
    if (userId == null) throw Exception('Please log in to like games.');

    // Rate limit: 800ms between likes per user
    final now = DateTime.now();
    final rateKey = '${gameId}_$userId';
    if (_lastLikeTime.containsKey(rateKey)) {
      final diff = now.difference(_lastLikeTime[rateKey]!);
      if (diff < const Duration(milliseconds: 800)) {
        throw Exception('Slow down! You are liking too fast.');
      }
    }
    _lastLikeTime[rateKey] = now;

    try {
      await _ensureGame(metadata);

      final existing = await _client
          .from('game_likes')
          .select('game_id')
          .eq('game_id', gameId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing == null) {
        await _client.from('game_likes').insert({
          'game_id': gameId,
          'user_id': userId,
        });
        await _upsertUserState(gameId: gameId, userId: userId, liked: true);
      } else {
        await _client
            .from('game_likes')
            .delete()
            .match({'game_id': gameId, 'user_id': userId});
        await _upsertUserState(gameId: gameId, userId: userId, liked: false);
      }
    } catch (e) {
      debugPrint('GameSocialService.toggleLike error: $e');
      rethrow;
    }
  }

  static Future<void> toggleSave({
    required String gameId,
    required String? userId,
    required bool currentlySaved,
  }) async {
    if (userId == null) return;
    try {
      if (currentlySaved) {
        await _client
            .from('game_saves')
            .delete()
            .match({'game_id': gameId, 'user_id': userId});
      } else {
        await _client.from('game_saves').upsert({
          'game_id': gameId,
          'user_id': userId,
        }, onConflict: 'game_id,user_id');
      }
      await _upsertUserState(
        gameId: gameId,
        userId: userId,
        saved: !currentlySaved,
      );
    } catch (e) {
      debugPrint('GameSocialService.toggleSave error: $e');
      rethrow;
    }
  }

  static Future<void> share({
    required String gameId,
    required UserModel? user,
    required GameSocialMetadata metadata,
  }) async {
    if (user == null) return;
    try {
      await _ensureGame(metadata);
      await _client.from('game_shares').insert({
        'game_id': gameId,
        'user_id': user.id,
        'username': user.username,
      });
    } catch (e) {
      debugPrint('GameSocialService.share error: $e');
    }
  }

  static Future<void> addComment({
    required String gameId,
    required UserModel? user,
    required String text,
    required GameSocialMetadata metadata,
    String? parentCommentId,
  }) async {
    if (user == null) throw Exception('Please log in to comment.');

    final trimmed = text.trim();
    if (trimmed.isEmpty) throw Exception('Comment cannot be empty.');
    if (trimmed.length < 2) {
      throw Exception('Comment is too short (min 2 characters).');
    }
    if (trimmed.length > 300) {
      throw Exception('Comment is too long (max 300 characters).');
    }

    // Anti-spam: check links/URLs
    final lowercaseText = trimmed.toLowerCase();
    if (lowercaseText.contains('http://') ||
        lowercaseText.contains('https://') ||
        lowercaseText.contains('www.') ||
        RegExp(r'\b[a-zA-Z0-9.-]+\.(com|net|org|edu|gov|mil|io|co|xyz)\b').hasMatch(lowercaseText)) {
      throw Exception('Links/URLs are not allowed in comments.');
    }

    // Anti-spam: check duplicate text
    if (_lastCommentText == trimmed) {
      throw Exception('You just posted the same comment. Duplicate blocked.');
    }

    // Rate Limit: 3 seconds between comments per user
    final now = DateTime.now();
    final rateKey = '${gameId}_${user.id}';
    if (_lastCommentTime.containsKey(rateKey)) {
      final diff = now.difference(_lastCommentTime[rateKey]!);
      if (diff < const Duration(seconds: 3)) {
        throw Exception('Please wait 3 seconds before commenting again.');
      }
    }

    _lastCommentTime[rateKey] = now;
    _lastCommentText = trimmed;

    try {
      await _ensureGame(metadata);
      await _client.from('game_comments').insert({
        'game_id': gameId,
        'user_id': user.id,
        'username': user.username,
        'avatar_initials': user.avatarInitials,
        'text': trimmed,
        if (parentCommentId != null) 'parent_comment_id': parentCommentId,
      });
    } catch (e) {
      debugPrint('GameSocialService.addComment error: $e');
      rethrow;
    }
  }

  static Future<void> _ensureGame(GameSocialMetadata metadata) async {
    await _client.from('games').upsert({
      'id': metadata.gameId,
      'name': metadata.name,
      'description': metadata.description,
      'emoji': metadata.emoji,
      'tag': metadata.tag,
      'rating': metadata.rating,
    }, onConflict: 'id', ignoreDuplicates: true);
    await _client.from('game_social_stats').upsert({
      'game_id': metadata.gameId,
    }, onConflict: 'game_id', ignoreDuplicates: true);
  }

  static Future<void> _upsertUserState({
    required String gameId,
    required String userId,
    bool? liked,
    bool? saved,
  }) async {
    await _client.from('game_user_states').upsert({
      'game_id': gameId,
      'user_id': userId,
      if (liked != null) 'liked': liked,
      if (saved != null) 'saved': saved,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'game_id,user_id');
  }
}
