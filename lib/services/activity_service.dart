import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class ActivityService {
  ActivityService._();

  static final SupabaseClient _client = SupabaseService.client;

  static Stream<List<Map<String, dynamic>>> globalActivity() {
    return _client
        .from('activity_logs')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(50);
  }

  static Future<void> log({
    required String type,
    required String message,
    String? actorId,
    String? targetUserId,
    Map<String, dynamic>? metadata,
  }) {
    return _client.from('activity_logs').insert({
      'type': type,
      'message': message,
      if (actorId != null) 'actor_id': actorId,
      if (targetUserId != null) 'target_user_id': targetUserId,
      'metadata': metadata ?? <String, dynamic>{},
    });
  }
}
