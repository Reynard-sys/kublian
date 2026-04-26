// lib/core/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lazy — only instantiated on non-web platforms to avoid the
  // "ClientID not set" assertion thrown by google_sign_in_web at init time.
  GoogleSignIn? _googleSignIn;
  GoogleSignIn get _gsi => _googleSignIn ??= GoogleSignIn();

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
  /// On web, uses the Firebase popup flow; on mobile, uses google_sign_in.
  /// Returns the signed-in [User], or null if the user cancelled or an error occurred.
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web: use Firebase's built-in Google provider popup — no client ID config needed here.
        final provider = GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(provider);
        return userCredential.user;
      } else {
        // Mobile / desktop: use google_sign_in package
        final GoogleSignInAccount? googleUser = await _gsi.signIn();
        if (googleUser == null) return null; // User cancelled

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'AuthService.signInWithGoogle FirebaseAuthException: '
        'code=${e.code}, message=${e.message}',
      );
      return null;
    } catch (e, st) {
      debugPrint('AuthService.signInWithGoogle error: $e');
      debugPrint('$st');
      return null;
    }
  }

  /// Anonymous Sign-In — fallback for users who don't want to link an account.
  /// Returns the signed-in [User], or null on failure.
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'AuthService.signInAnonymously FirebaseAuthException: '
        'code=${e.code}, message=${e.message}',
      );
      return null;
    } catch (e, st) {
      debugPrint('AuthService.signInAnonymously error: $e');
      debugPrint('$st');
      return null;
    }
  }

  // ==========================================
  // SIGN OUT
  // ==========================================

  Future<void> signOut() async {
    if (!kIsWeb) {
      await _gsi.signOut();
    }
    await _auth.signOut();
  }
}
