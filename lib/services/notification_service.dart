import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class NotificationService {
  NotificationService._();

  static final SupabaseClient _client = SupabaseService.client;

  static Stream<List<Map<String, dynamic>>> notifications(String userId) {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(100);
  }

  static Future<void> markRead(String notificationId) {
    return _client
        .from('notifications')
        .update({'read_at': DateTime.now().toIso8601String()})
        .eq('id', notificationId);
  }
}
