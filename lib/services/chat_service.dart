import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class ChatService {
  ChatService._();

  static final SupabaseClient _client = SupabaseService.client;

  static Stream<List<Map<String, dynamic>>> messages(String chatId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at')
        .limit(200);
  }

  static Future<void> sendMessage({
    required String chatId,
    required String text,
  }) {
    final userId = SupabaseService.userId;
    if (userId == null || text.trim().isEmpty) return Future.value();
    return _client.from('messages').insert({
      'chat_id': chatId,
      'sender_id': userId,
      'text': text.trim(),
    });
  }
}
