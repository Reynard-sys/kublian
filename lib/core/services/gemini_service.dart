// lib/core/services/gemini_service.dart

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  late final GenerativeModel _fastModel;

  GeminiService() {
    // Ideally, pass this securely via --dart-define or flutter_dotenv
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');
    if (apiKey.isEmpty && !kReleaseMode) {
      debugPrint('WARNING: Gemini API Key is missing.');
    }

    // Using gemini-2.5-flash (intentional upgrade over MD spec of 2.0-flash)
    _fastModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
  }

  // ==========================================
  // 1. VOLUNTEER MATCHING
  // ==========================================
  Future<String?> matchVolunteer(Map<String, dynamic> intakeForm, List<Map<String, dynamic>> volunteerPool) async {
    final poolString = volunteerPool.map((v) => 
      "ID: ${v['id']}, Role: ${v['role']}, Specialties: ${v['specialtyTags'].join(', ')}, Exp: ${v['experienceTags'].join(', ')}, Rating: ${v['rating']}"
    ).join('\n');

    final prompt = """
    You are a mental health volunteer matching system for the Philippines.
    
    User Intake Form:
    - Mood score (1-10): ${intakeForm['moodScore']}
    - Situation tags: ${intakeForm['situationTags']?.join(', ')}
    - Support type needed: ${intakeForm['supportType']}
    - Previous session summary context: ${intakeForm['lastSessionSummary'] ?? 'None'}

    Available volunteers:
    $poolString

    Match the user to the single most suitable volunteer. 
    Return ONLY the exact volunteer ID string (e.g., v_003). Do not explain.
    """;

    try {
      final response = await _fastModel.generateContent([Content.text(prompt)]);
      return response.text?.trim();
    } catch (e) {
      debugPrint('Gemini Matching Error: $e');
      return null; // Handle fallback in your calling logic
    }
  }

  // ==========================================
  // 2. CHAT SESSION PERSONA
  // ==========================================
  Future<String> generateChatResponse(
    List<Map<String, dynamic>> messages, 
    Map<String, dynamic> volunteer,
    String? previousSummary
  ) async {
    final systemPrompt = _buildSystemPrompt(volunteer, previousSummary);
    
    // Convert your Firestore message map to Gemini Content objects
    final history = messages.map((m) {
      final role = m['senderId'] == 'user' ? 'user' : 'model';
      return Content(role, [TextPart(m['text'] as String)]);
    }).toList();

    try {
      // Create a temporary model instance with the injected system instructions
      final personaModel = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: String.fromEnvironment('GEMINI_API_KEY'),
        systemInstruction: Content.system(systemPrompt),
      );

      // Start chat with history
      final chat = personaModel.startChat(history: history);
      
      // We don't send a new message because the user's last message is already in the history.
      // We just need the model to react to the history. 
      // Workaround: remove the last user message from history and send it as the prompt.
      if (history.isEmpty) return "Sige, nandito lang ako kung kailangan mo ng kausap.";
      
      final lastUserMessage = history.removeLast();
      final response = await chat.sendMessage(lastUserMessage);
      
      return response.text ?? "I'm here for you.";
    } catch (e) {
      debugPrint('Gemini Chat Error: $e');
      return "Sorry, nagkakaroon ako ng slight connection issue. Dito lang ako, please give me a moment.";
    }
  }

  // ==========================================
  // 3. HANDOVER SUMMARY (Triggered via UI Button)
  // ==========================================
  Future<String> generateSessionSummary(
    List<Map<String, dynamic>> messages, 
    Map<String, dynamic> volunteer
  ) async {
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
    } catch (e) {
      debugPrint('Gemini Summary Error: $e');
      return "Session completed but summary generation failed.";
    }
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