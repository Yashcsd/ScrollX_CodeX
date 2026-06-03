import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class AuthService {
  AuthService._();

  static final SupabaseClient _client = SupabaseService.client;

  static User? get currentUser => _client.auth.currentUser;
  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  static Future<AuthResponse> signInAsGuest({Map<String, dynamic>? data}) {
    return _client.auth.signInAnonymously(data: data);
  }

  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  static Future<bool> signInWithGoogle() {
    return _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.scrollx://login-callback/',
    );
  }

  static Future<void> signOut() => _client.auth.signOut();
}
