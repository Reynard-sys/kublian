// lib/core/services/user_service.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==========================================
  // ALIAS GENERATION
  // ==========================================

  static const _adjectives = [
    'Starling', 'Golden', 'Silver', 'Amber', 'Misty', 'Quiet', 'Gentle',
    'Calm', 'Serene', 'Bright', 'Swift', 'Soft', 'Warm', 'Still', 'Ember',
    'Hollow', 'Willow', 'Tender', 'Mossy', 'Drifting',
  ];

  static const _nouns = [
    'Mist', 'River', 'Pine', 'Fog', 'Light', 'Wave', 'Star', 'Leaf',
    'Moon', 'Brook', 'Dawn', 'Dusk', 'Bloom', 'Fern', 'Gale',
    'Tide', 'Reed', 'Haze', 'Crest', 'Veil',
  ];

  /// Generates a random anonymous alias (e.g., "StarlingMist42").
  /// Alias is system-generated — users never choose their own.
  String generateAlias() {
    final rng = Random();
    final adj = _adjectives[rng.nextInt(_adjectives.length)];
    final noun = _nouns[rng.nextInt(_nouns.length)];
    final num = rng.nextInt(90) + 10; // 10–99
    return '$adj$noun$num';
  }

  // ==========================================
  // PROFILE CRUD
  // ==========================================

  /// Creates the user's Firestore profile document on first sign-in.
  /// Matches the `users/{userId}` schema from the MD exactly.
  Future<void> createUserProfile({
    required String uid,
    required String alias,
    required String ageGroup,
    required String cityLocation,
    String? genderIdentity,
    String? aboutMe,
    String? previousHistory,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'alias': alias,
      'ageGroup': ageGroup,
      'cityLocation': cityLocation,
      'genderIdentity':
          genderIdentity != null && genderIdentity.trim().isNotEmpty
              ? genderIdentity.trim()
              : null,
      'aboutMe': aboutMe != null && aboutMe.trim().isNotEmpty
          ? aboutMe.trim()
          : null,
      'previousHistory':
          previousHistory != null && previousHistory.trim().isNotEmpty
              ? previousHistory.trim()
              : null,
      'createdAt': FieldValue.serverTimestamp(),
      'blockedVolunteers': [],
      'activeSessionId': null,
      'lastSessionSummary': null,
    });
  }

  /// Returns the user's Firestore profile, or null if it doesn't exist yet.
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      debugPrint('UserService.getUserProfile error: $e');
      return null;
    }
  }

  /// Checks whether a user profile exists — used to decide whether to
  /// show the alias setup screen on first sign-in.
  Future<bool> userProfileExists(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      debugPrint('UserService.userProfileExists error: $e');
      return false;
    }
  }

  // ==========================================
  // SESSION MANAGEMENT
  // ==========================================

  Future<void> updateActiveSession(String uid, String sessionId) async {
    await _firestore.collection('users').doc(uid).update({
      'activeSessionId': sessionId,
    });
  }

  Future<void> clearActiveSession(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'activeSessionId': null,
    });
  }

  // ==========================================
  // BLOCK LIST
  // ==========================================

  /// Adds a volunteer to the user's block list.
  /// Blocked volunteers are excluded from future Gemini matching.
  Future<void> blockVolunteer(String uid, String volunteerId) async {
    await _firestore.collection('users').doc(uid).update({
      'blockedVolunteers': FieldValue.arrayUnion([volunteerId]),
    });
  }
}
