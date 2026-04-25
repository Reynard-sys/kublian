// lib/core/services/session_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'gemini_service.dart';

class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GeminiService _geminiService;
  final _uuid = const Uuid();

  SessionService(this._geminiService);

  // ==========================================
  // SESSION LIFECYCLE
  // ==========================================

  /// Creates a new session document and marks it active on the user profile.
  /// Returns the generated [sessionId].
  Future<String> createSession({
    required String userId,
    required String userAlias,
    required String volunteerId,
    required Map<String, dynamic> intakeForm,
  }) async {
    final sessionId = _uuid.v4();

    await _firestore.collection('sessions').doc(sessionId).set({
      'id': sessionId,
      'userId': userId,
      'userAlias': userAlias,
      'volunteerId': volunteerId,
      'status': 'active',
      'startedAt': FieldValue.serverTimestamp(),
      'endedAt': null,
      'endType': null, // 'soft' | 'force' — set on close
      'escalationLevel': 0,
      'intakeForm': intakeForm,
      'summaryId': null,
    });

    await _firestore.collection('users').doc(userId).update({
      'activeSessionId': sessionId,
    });

    return sessionId;
  }

  // ==========================================
  // MESSAGES
  // ==========================================

  /// Sends a message to the session's ephemeral messages subcollection.
  Future<void> sendMessage({
    required String sessionId,
    required String senderId, // 'user' or volunteer ID
    required String text,
  }) async {
    final messageId = _uuid.v4();
    await _firestore
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .doc(messageId)
        .set({
      'id': messageId,
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Fetches all messages for a session ordered by timestamp (one-shot).
  Future<List<Map<String, dynamic>>> getMessages(String sessionId) async {
    final snapshot = await _firestore
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Real-time stream of messages — used by the chat screen.
  Stream<List<Map<String, dynamic>>> messagesStream(String sessionId) {
    return _firestore
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  // ==========================================
  // ESCALATION
  // ==========================================

  /// Updates escalation level on the session.
  /// 0 = normal | 1 = Button 1 (pro alert) | 2 = Button 2 (extreme crisis)
  Future<void> setEscalationLevel(String sessionId, int level) async {
    await _firestore.collection('sessions').doc(sessionId).update({
      'escalationLevel': level,
    });
  }

  // ==========================================
  // SESSION CLOSE — USER INITIATED
  // ==========================================

  /// Ends the session gracefully.
  ///
  /// Flow:
  /// 1. Lock session to 'closing' (blocks new messages)
  /// 2. Fetch full chat history
  /// 3. Generate Gemini handover summary
  /// 4. Create summary doc (volunteerRating/Feedback = null — filled later)
  /// 5. Save summary context to user profile for next session intake
  /// 6. Set status → 'closed' (triggers Cloud Function to delete messages)
  ///
  /// Returns [geminiSummary] so the UI can display it **in-memory** without
  /// re-reading Firestore. Per updated rules, users cannot read closed sessions
  /// or summaries — the summary card must use this returned value directly.
  Future<({String summaryId, String geminiSummary})> endSessionUserInitiated({
    required String sessionId,
    required String userId,
    required Map<String, dynamic> volunteerData,
  }) async {
    // 1. Lock session
    await _firestore.collection('sessions').doc(sessionId).update({
      'status': 'closing',
    });

    // 2. Fetch history
    final messages = await getMessages(sessionId);

    // 3. Generate handover summary via Gemini
    final geminiSummary =
        await _geminiService.generateSessionSummary(messages, volunteerData);

    // 4. Create summary doc — rating fields null until post-session form
    final summaryRef = _firestore.collection('summaries').doc();
    await summaryRef.set({
      'id': summaryRef.id,
      'sessionId': sessionId,
      'userId': userId,
      'volunteerId': volunteerData['id'],
      'geminiSummary': geminiSummary,
      'volunteerRating': null,     // filled by submitPostSessionRating()
      'volunteerFeedback': null,   // filled by submitPostSessionRating()
      'flaggedForReview': false,
      'sharedWithVolunteerId': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 5. Persist summary context on user doc for next intake form
    await _firestore.collection('users').doc(userId).update({
      'lastSessionSummary': geminiSummary,
      'activeSessionId': null,
    });

    // 6. Close session — triggers deleteMessagesOnSessionClose Cloud Function
    await _firestore.collection('sessions').doc(sessionId).update({
      'status': 'closed',
      'endedAt': FieldValue.serverTimestamp(),
      'endType': 'soft', // Per MD schema: 'soft' | 'force'
      'summaryId': summaryRef.id,
    });

    return (summaryId: summaryRef.id, geminiSummary: geminiSummary);
  }

  /// Ends the session immediately without generating a handover summary.
  Future<void> endSessionForce({
    required String sessionId,
    required String userId,
  }) async {
    final batch = _firestore.batch();

    batch.update(_firestore.collection('users').doc(userId), {
      'activeSessionId': null,
    });

    batch.update(_firestore.collection('sessions').doc(sessionId), {
      'status': 'closed',
      'endedAt': FieldValue.serverTimestamp(),
      'endType': 'force',
    });

    await batch.commit();
  }

  /// Creates a moderation report tied to a volunteer and, when available,
  /// the session the user just ended.
  Future<void> createVolunteerReport({
    required String userId,
    required String volunteerId,
    String? sessionId,
    String? details,
    String source = 'hard_end',
  }) async {
    final reportRef = _firestore.collection('reports').doc();
    await reportRef.set({
      'id': reportRef.id,
      'type': 'volunteer',
      'source': source,
      'userId': userId,
      'volunteerId': volunteerId,
      'sessionId': sessionId,
      'details': details != null && details.trim().isNotEmpty
          ? details.trim()
          : null,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ==========================================
  // POST-SESSION RATING
  // ==========================================

  /// Updates ONLY volunteerRating and volunteerFeedback on the summary doc.
  ///
  /// This is a separate write from session close — required by the Firestore
  /// security rule that enforces diff().affectedKeys().hasOnly([...]) on
  /// summary updates. Any attempt to modify other fields will be rejected.
  Future<void> submitPostSessionRating({
    required String summaryId,
    required int rating,
    String? feedback,
  }) async {
    await _firestore.collection('summaries').doc(summaryId).update({
      'volunteerRating': rating,
      'volunteerFeedback': feedback,
    });
  }
}
