import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class RealtimeService {
  RealtimeService._();

  static SupabaseStreamBuilder streamTable(
    String table, {
    required List<String> primaryKey,
  }) {
    return SupabaseService.client.from(table).stream(primaryKey: primaryKey);
  }

  static RealtimeChannel channel(String name) {
    return SupabaseService.client.channel(name);
  }

  static Future<void> removeChannel(RealtimeChannel channel) {
    return SupabaseService.client.removeChannel(channel);
  }
}
