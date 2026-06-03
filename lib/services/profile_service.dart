import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import 'supabase_service.dart';

class ProfileService {
  ProfileService._();

  static final SupabaseClient _client = SupabaseService.client;

  static Future<UserModel?> getProfile(String userId) async {
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (row == null) return null;
    return UserModel.fromMap(row, userId);
  }

  static Future<UserModel> upsertProfile(UserModel user) async {
    final row = await _client
        .from('profiles')
        .upsert(user.toMap()..['id'] = user.id, onConflict: 'id')
        .select()
        .single();
    return UserModel.fromMap(row, row['id'] as String);
  }

  static Future<void> updateProfile(UserModel user) async {
    await _client.from('profiles').update(user.toMap()).eq('id', user.id);
  }

  static Stream<List<UserModel>> leaderboardStream({String period = 'all_time'}) {
    return _client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .order('total_xp', ascending: false)
        .limit(100)
        .map(
          (rows) => rows
              .map((row) => UserModel.fromMap(row, row['id'] as String))
              .toList(),
        );
  }

  static Future<List<UserModel>> suggestedUsers({int limit = 20}) async {
    final rows = await _client
        .from('profiles')
        .select()
        .order('total_xp', ascending: false)
        .limit(limit);
    return rows
        .map((row) => UserModel.fromMap(row, row['id'] as String))
        .toList();
  }

  static Future<void> follow(String targetUserId) async {
    final userId = SupabaseService.userId;
    if (userId == null || userId == targetUserId) return;
    await _client.from('followers').upsert({
      'follower_id': userId,
      'following_id': targetUserId,
    }, onConflict: 'follower_id,following_id');
  }

  static Future<void> unfollow(String targetUserId) async {
    final userId = SupabaseService.userId;
    if (userId == null) return;
    await _client
        .from('followers')
        .delete()
        .match({'follower_id': userId, 'following_id': targetUserId});
  }
}
