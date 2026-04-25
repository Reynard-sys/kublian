// lib/core/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ==========================================
  // STATE
  // ==========================================

  /// Stream of Firebase auth state — use this in StreamBuilder to gate navigation.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently signed-in Firebase user, or null if not authenticated.
  User? get currentUser => _auth.currentUser;

  // ==========================================
  // SIGN IN
  // ==========================================

  /// Google Sign-In via Firebase Auth.
  /// Returns the signed-in [User], or null if the user cancelled or an error occurred.
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled the picker

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      debugPrint('AuthService.signInWithGoogle error: $e');
      return null;
    }
  }

  /// Anonymous Sign-In — fallback for users who don't want to link an account.
  /// Returns the signed-in [User], or null on failure.
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      debugPrint('AuthService.signInAnonymously error: $e');
      return null;
    }
  }

  // ==========================================
  // SIGN OUT
  // ==========================================

  Future<void> signOut() async {
    await Future.wait([
      _googleSignIn.signOut(),
      _auth.signOut(),
    ]);
  }
}
