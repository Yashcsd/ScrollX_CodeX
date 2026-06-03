import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase_config.dart';

class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() {
    return Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.publishableKey,
    );
  }

  static String? get userId => client.auth.currentUser?.id;
  static bool get isSignedIn => client.auth.currentSession != null;
}
