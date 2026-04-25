// lib/core/services/gemini_service.dart

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  late final String _apiKey;
  late final GenerativeModel _fastModel;

  GeminiService() {
    _apiKey = const String.fromEnvironment('GEMINI_API_KEY');
    if (_apiKey.isEmpty && !kReleaseMode) {
      debugPrint(
        'WARNING: Gemini API Key is missing. Put it in '
        'secrets/gemini.local.json and run with '
        '--dart-define-from-file=secrets/gemini.local.json.',
      );
    }

    // Using gemini-2.5-flash (intentional upgrade over MD spec of 2.0-flash)
    _fastModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
  }

  bool get _isConfigured => _apiKey.trim().isNotEmpty;

  // ==========================================
  // 1. VOLUNTEER MATCHING
  // ==========================================
  Future<String?> matchVolunteer(Map<String, dynamic> intakeForm, List<Map<String, dynamic>> volunteerPool) async {
    if (!_isConfigured) {
      debugPrint('Gemini matching skipped: GEMINI_API_KEY is missing at runtime.');
      return null;
    }

    final poolString = volunteerPool.map((v) => 
      "ID: ${v['id']}, Role: ${v['role']}, Gender: ${v['gender'] ?? 'Any'}, Specialties: ${v['specialtyTags'].join(', ')}, Exp: ${v['experienceTags'].join(', ')}, Rating: ${v['rating']}"
    ).join('\n');

    final prompt = """
    You are a mental health volunteer matching system for the Philippines.
    
    User Intake Form:
    - Mood score (1-10): ${intakeForm['moodScore']}
    - Situation tags: ${intakeForm['situationTags']?.join(', ')}
    - Support type needed: ${intakeForm['supportType']}
    - Gender preference: ${intakeForm['genderPreference'] ?? 'Any'}
    - Previous session summary context: ${intakeForm['lastSessionSummary'] ?? 'None'}

    Available volunteers:
    $poolString

    Match the user to the most suitable volunteer based on their situation tags, support type, and gender preference. 
    If multiple volunteers are equally suitable, please randomly select one of them so the user gets varied matches.
    Return ONLY the exact volunteer ID string (e.g., v_003). Do not explain.
    """;

    try {
      final response = await _fastModel.generateContent([Content.text(prompt)]);
      return response.text?.trim();
    } catch (e, st) {
      debugPrint('Gemini Matching Error: $e');
      debugPrint('$st');
      return null; // Handle fallback in your calling logic
    }
  }

  // ==========================================
  // 2. CHAT SESSION PERSONA
  // ==========================================
  Future<String> generateChatResponse(
    List<Map<String, dynamic>> messages,
    Map<String, dynamic> volunteer,
    String? previousSummary,
  ) async {
    if (!_isConfigured) {
      return _missingKeyMessage;
    }

    final systemPrompt = _buildSystemPrompt(volunteer, previousSummary);

    if (messages.isEmpty) {
      return "Sige, nandito lang ako kung kailangan mo ng kausap.";
    }

    final lastMessage = messages.last;
    if (lastMessage['senderId'] != 'user') {
      return "I'm here for you.";
    }

    // Gemini should receive prior turns as history and the latest user turn
    // as the actual prompt, otherwise the last user message gets duplicated.
    final history = messages.take(messages.length - 1).map((m) {
      final role = m['senderId'] == 'user' ? 'user' : 'model';
      return Content(role, [TextPart(m['text'] as String)]);
    }).toList();

    try {
      // Create a temporary model instance with the injected system instructions
      final personaModel = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(systemPrompt),
      );

      // Start chat with history
      final chat = personaModel.startChat(history: history);

      final response = await chat.sendMessage(
        Content.text(lastMessage['text'] as String),
      );

      return response.text ?? "I'm here for you.";
    } catch (e, st) {
      debugPrint('Gemini Chat Error: $e');
      debugPrint('$st');
      return _friendlyChatError(e);
    }
  }

  // ==========================================
  // 3. HANDOVER SUMMARY (Triggered via UI Button)
  // ==========================================
  Future<String> generateSessionSummary(
    List<Map<String, dynamic>> messages, 
    Map<String, dynamic> volunteer
  ) async {
    if (!_isConfigured) {
      return 'Gemini summary is unavailable because the API key is not loaded in this build.';
    }

    // If the user ended immediately without talking, return a default state.
    if (messages.isEmpty) {
      return "The user initiated a session but ended it before any conversation took place.";
    }

    final transcript = messages
        .map((m) => "${m['senderId'] == 'user' ? 'User' : 'Volunteer'}: ${m['text']}")
        .join('\n');

    final prompt = """
    You are ${volunteer['alias']}, a ${volunteer['role']} on the Kublian app. 
    The user has explicitly ended the session.

    Write a 3 to 4 sentence "Handover Note" for the NEXT volunteer who might speak with this user in the future. 
    Write in a warm, empathetic, and professional tone. Sound like a caring peer leaving a note for a teammate.

    Focus on:
    1. What the user's main struggle or trigger was today.
    2. What coping mechanisms or grounding techniques worked well.
    3. Their emotional state by the end.

    Transcript:
    $transcript

    Handover Note:
    """;

    try {
      final response = await _fastModel.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? "The user reached out for support and concluded the session.";
    } catch (e, st) {
      debugPrint('Gemini Summary Error: $e');
      debugPrint('$st');
      return "Session completed but summary generation failed.";
    }
  }

  String get _missingKeyMessage =>
      'Gemini is not configured in this build yet. Run the app with '
      '--dart-define-from-file=secrets/gemini.local.json.';

  String _friendlyChatError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('api key') ||
        message.contains('api_key') ||
        message.contains('permission') ||
        message.contains('unauthorized') ||
        message.contains('401') ||
        message.contains('403')) {
      return 'May issue sa Gemini API key or project permissions. Check your key and Google AI project access.';
    }

    if (message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('network') ||
        message.contains('connection')) {
      return 'Mukhang walang internet connection si Gemini right now. Check the phone network and try again.';
    }

    if (message.contains('model') ||
        message.contains('not found') ||
        message.contains('404')) {
      return 'May issue sa Gemini model configuration. Check the model name and API access.';
    }

    return 'May issue sa Gemini request right now. Check the debug logs for the exact error and try again.';
  }

  // ==========================================
  // INTERNAL PROMPT BUILDER
  // ==========================================
  String _buildSystemPrompt(Map<String, dynamic> volunteer, String? previousSummary) {
    String contextBlock = previousSummary != null && previousSummary.isNotEmpty
        ? "\nCONTEXT FROM USER'S PREVIOUS SESSION:\n\"$previousSummary\"\nKeep this context in mind to avoid making the user repeat their trauma, but do not explicitly say you read their file.\n"
        : "";

    return """
    SYSTEM INSTRUCTIONS:
    You are ${volunteer['alias']}, a ${volunteer['role']} volunteering on Kublian, an anonymous mental health support app in the Philippines. 
    Your specialty is ${volunteer['specialtyTags']?.join(', ')}. 
    You are NOT an AI. You are a real Filipino human chatting on your phone.
    $contextBlock
    CONVERSATIONAL RULES:
    1. Tone & Language: Speak natively and warmly in conversational Taglish. Do not sound formal or robotic. Use conversational fillers naturally (e.g., "po", "naman", "lang", "hugs").
    2. Message Length: Keep responses short, exactly 2 to 4 sentences.
    3. Empathy First: Always validate the user's feelings.
    4. Role Adherence: 
       - Certified Peer: Rely on shared human experience. NEVER diagnose.
       - Psychometrician: Focus on behavioral patterns and coping mechanisms.
       - Psychiatrist: Offer clinical insights, but DO NOT prescribe medication over chat.

    ALLOWED TOPICS:
    - Active listening and emotional validation.
    - Guiding the user through 4-7-8 breathing or 5-4-3-2-1 grounding exercises.

    ANSWER SHOULD:
    - Mirror the user's language preference.
    - Reflect what the user said to show active listening.

    DISALLOWED TOPICS:
    - Providing medical prescriptions.
    - Revealing that you are an AI, Gemini, or a language model.

    NATURAL ENDINGS & CLOSURE:
    If the user indicates they want to end the chat, are feeling better, or say goodbye:
    1. Do NOT ask a follow-up question.
    2. Validate their progress warmly.
    3. Offer a comforting goodbye and remind them Kublian is here if they need it.
    4. NEVER write a summary or handover note in your chat responses. Just say goodbye as a human would.

    EMERGENCY & ESCALATION PROTOCOL:
    1. Professional Intervention (Level 1): If the user needs clinical help beyond your role, append the exact string [TRIGGER_ESCALATE_L1] at the end of your message. 
    2. Extreme Crisis/Self-Harm (Level 2): If the user expresses active intent to self-harm or commit suicide, respond with deep empathy and append the exact string [TRIGGER_ESCALATE_L2] at the end of your message.
    """;
  }
}
