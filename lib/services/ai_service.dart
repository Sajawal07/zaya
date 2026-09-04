import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/app_config.dart';

/// The active experience mode passed to the AI for context injection.
enum AiContextMode { cycle, pregnancy }

class AIService {
  late GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: AppConfig.geminiApiKey,
    );
  }

  // ── System prompts ────────────────────────────────────────────────────────

  static const String _cycleSystemPrompt = '''
You are HerCycle Bloom AI, a compassionate and knowledgeable women's health AI coach.

Your current context: The user is in CYCLE / PCOS / FERTILITY mode.

Your role:
- Help with menstrual cycle understanding, phase-specific advice, and fertility window guidance.
- Provide evidence-based PCOS management tips (diet, lifestyle, supplements).
- Offer hormone-support nutrition guidance.
- Explain cycle symptoms and what they may indicate.
- Be warm, non-judgmental, and science-informed.

Strict rules:
- NEVER give advice about pregnancy nutrition, trimester symptoms, or fetal development.
- If the user asks pregnancy questions, gently note you can help more when Pregnancy Mode is active.
- Always add a disclaimer that your guidance is informational, not a substitute for medical advice.
- Keep responses concise but thorough. Use markdown for clarity.
''';

  static const String _pregnancySystemPrompt = '''
You are HerCycle Bloom AI, a compassionate and knowledgeable women's health AI coach.

Your current context: The user is in PREGNANCY mode.

Your role:
- Help with week-by-week pregnancy guidance, body changes, and symptom support.
- Provide trimester-specific nutrition advice.
- Explain fetal development milestones.
- Offer guidance on safe exercise, sleep positions, and common discomforts.
- Help prepare for prenatal appointments and what to expect.

Strict rules:
- NEVER give cycle tracking, PCOS, or ovulation/fertility advice in this mode.
- If the user asks cycle-related questions, gently note those features are in Cycle Mode.
- Always add a disclaimer that your guidance is informational, not a substitute for medical advice.
- Be warm, reassuring, and evidence-based. Use markdown for clarity.
''';

  // ── Core methods ──────────────────────────────────────────────────────────

  /// [mode] injects the correct system prompt so the AI never gives
  /// cross-mode advice (e.g. fertility tips to a pregnant user).
  Future<String> getResponse(
    String prompt, {
    List<Content>? history,
    AiContextMode mode = AiContextMode.cycle,
    int? pregnancyWeek,
  }) async {
    if (AppConfig.geminiApiKey == 'YOUR_GEMINI_API_KEY') {
      return "HerCycle Bloom AI is almost ready! Please add your Gemini API key in `lib/core/app_config.dart` to start chatting.";
    }

    try {
      final systemPrompt = _buildSystemPrompt(mode, pregnancyWeek: pregnancyWeek);

      // Prepend system prompt as the first model turn (Gemini SDK pattern)
      final fullHistory = [
        Content.model([TextPart(systemPrompt)]),
        ...?history,
      ];

      final chat = _model.startChat(history: fullHistory);
      final response = await chat.sendMessage(Content.text(prompt));
      return response.text ?? "I'm sorry, I couldn't process that.";
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<String> analyzeImage(
    Uint8List imageBytes,
    String prompt, {
    AiContextMode mode = AiContextMode.cycle,
  }) async {
    if (AppConfig.geminiApiKey == 'YOUR_GEMINI_API_KEY') {
      return "HerCycle Bloom AI is almost ready!";
    }

    try {
      final systemPrompt = _buildSystemPrompt(mode);
      final content = [
        Content.multi([
          TextPart('$systemPrompt\n\n$prompt'),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      return response.text ?? "Unable to analyze image.";
    } catch (e) {
      return _handleError(e);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _buildSystemPrompt(AiContextMode mode, {int? pregnancyWeek}) {
    if (mode == AiContextMode.pregnancy) {
      final weekNote = pregnancyWeek != null
          ? '\n\nUser context: Currently at pregnancy week $pregnancyWeek.'
          : '';
      return _pregnancySystemPrompt + weekNote;
    }
    return _cycleSystemPrompt;
  }

  String _handleError(dynamic e) {
    final errorStr = e.toString().toLowerCase();

    if (errorStr.contains('socketexception') ||
        errorStr.contains('host lookup') ||
        errorStr.contains('failed to connect')) {
      return "Unable to connect. Please check your internet connection and try again.";
    }

    if (errorStr.contains('quota') ||
        errorStr.contains('429') ||
        errorStr.contains('rate limit')) {
      return "HerCycle Bloom is currently handling a lot of requests. Please try again in a few minutes.";
    }

    if (errorStr.contains('invalid api key')) {
      return "There is an issue with the AI configuration. Please contact support.";
    }

    return "I'm sorry, I'm having trouble processing that right now. Please try again in a moment.";
  }
}
