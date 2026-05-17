// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth  _auth         = FirebaseAuth.instance;
  static final GoogleSignIn  _googleSignIn = GoogleSignIn();

  static User?   get currentUser  => _auth.currentUser;
  static String? get displayName  => _auth.currentUser?.displayName;
  static String? get email        => _auth.currentUser?.email;
  static String? get uid          => _auth.currentUser?.uid;

  /// Sign in with Google.
  /// Returns the Firebase [User] on success, null on cancel or error.
  static Future<User?> signInWithGoogle() async {
    try {
      // 1. Trigger the Google sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('AuthService: user cancelled Google sign-in');
        return null;
      }

      // 2. Get auth tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Create Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );

      // 4. Sign in to Firebase
      final UserCredential result =
          await _auth.signInWithCredential(credential);

      debugPrint('AuthService: signed in as ${result.user?.displayName}');
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService FirebaseAuthException: ${e.code} — ${e.message}');
      return null;
    } catch (e) {
      debugPrint('AuthService error: $e');
      return null;
    }
  }

  /// Sign out from Firebase + Google
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('AuthService.signOut error: $e');
    }
  }
}
