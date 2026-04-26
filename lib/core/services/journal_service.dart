// lib/core/services/journal_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class JournalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  /// Shortcut to the user's private journal subcollection.
  /// Per Firestore rules: readable and writable ONLY by the owning user.
  CollectionReference<Map<String, dynamic>> _journalRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('journal');

  // ==========================================
  // WRITE
  // ==========================================

  /// Adds a new journal entry under `users/{uid}/journal/{entryId}`.
  ///
  /// [moodScore] — 1 to 10 (matches the session intake slider scale)
  /// [moodTag]   — short string label (e.g., 'anxious', 'calm', 'sad')
  /// [text]      — the user's private journal text
  Future<void> addEntry({
    required String uid,
    required int moodScore,
    required String moodTag,
    required String text,
  }) async {
    final entryId = _uuid.v4();
    await _journalRef(uid).doc(entryId).set({
      'id': entryId,
      'moodScore': moodScore,
      'moodTag': moodTag,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateEntry({
    required String uid,
    required String entryId,
    required int moodScore,
    required String moodTag,
    required String text,
  }) async {
    await _journalRef(uid).doc(entryId).update({
      'moodScore': moodScore,
      'moodTag': moodTag,
      'text': text,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==========================================
  // READ
  // ==========================================

  /// Returns a real-time stream of all journal entries, newest first.
  /// Use in a [StreamBuilder] on the Journal screen.
  Stream<List<Map<String, dynamic>>> getEntries(String uid) {
    return _journalRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }

  // ==========================================
  // DELETE
  // ==========================================

  Future<void> deleteEntry(String uid, String entryId) async {
    await _journalRef(uid).doc(entryId).delete();
  }
}
