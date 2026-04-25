import 'package:cloud_firestore/cloud_firestore.dart';
import 'gemini_service.dart';

class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GeminiService _geminiService;

  SessionService(this._geminiService);

  Future<void> endSessionUserInitiated({
    required String sessionId, 
    required String userId,
    required Map<String, dynamic> volunteerData
  }) async {
    try {
      // 1. Lock the session immediately to prevent new messages from being sent
      await _firestore.collection('sessions').doc(sessionId).update({
        'status': 'closing',
      });

      // 2. Fetch the complete chat history for this session
      final messagesSnapshot = await _firestore
          .collection('sessions')
          .doc(sessionId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      final messages = messagesSnapshot.docs.map((doc) => doc.data()).toList();

      // 3. Generate the Handover Summary via Gemini
      final handoverSummary = await _geminiService.generateSessionSummary(messages, volunteerData);

      // 4. Save the summary to the User's profile for the next session's context
      await _firestore.collection('users').doc(userId).update({
        'lastSessionSummary': handoverSummary,
        'activeSessionId': null, // Clear active session
      });

      // 5. Create the formal Summary Document (for Doctor Dashboard / Records)
      final summaryRef = _firestore.collection('summaries').doc();
      await summaryRef.set({
        'id': summaryRef.id,
        'sessionId': sessionId,
        'userId': userId,
        'volunteerId': volunteerData['id'],
        'geminiSummary': handoverSummary,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 6. Officially close the session
      // Note: If you have a Cloud Function listening for status == 'closed', 
      // it will now fire and delete the ephemeral messages subcollection.
      await _firestore.collection('sessions').doc(sessionId).update({
        'status': 'closed',
        'endedAt': FieldValue.serverTimestamp(),
        'endType': 'user_initiated',
        'summaryId': summaryRef.id,
      });

    } catch (e) {
      // Handle failure (e.g., show a snackbar in UI, retry logic, etc.)
      print("Failed to end session gracefully: \$e");
    }
  }
}