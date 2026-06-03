import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class PresenceService {
  PresenceService._();

  static final SupabaseClient _client = SupabaseService.client;

  static Future<void> setOnline({String? currentGameId}) async {
    final userId = SupabaseService.userId;
    if (userId == null) return;
    await _client.from('user_presence').upsert({
      'user_id': userId,
      'online': true,
      'current_game_id': currentGameId,
      'last_seen_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');
  }

  static Future<void> setOffline() async {
    final userId = SupabaseService.userId;
    if (userId == null) return;
    await _client.from('user_presence').upsert({
      'user_id': userId,
      'online': false,
      'last_seen_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');
  }

  static Stream<List<Map<String, dynamic>>> onlineUsers() {
    return _client
        .from('user_presence')
        .stream(primaryKey: ['user_id'])
        .eq('online', true);
  }
}
