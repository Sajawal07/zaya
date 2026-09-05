import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/app_config.dart';

/// The active experience mode passed to the AI for context injection.
enum AiContextMode { cycle, pregnancy }

class AIService {
  /// Ordered fallbacks — Google retires model IDs; keep a working default first.
  static const _modelCandidates = <String>[
    'gemini-flash-latest',
    'gemini-2.0-flash',
    'gemini-1.5-flash',
    'gemini-1.5-flash-latest',
  ];

  static const String _cycleSystemPrompt = '''
You are HerCycle Bloom AI — a warm, helpful women's health companion.

Context: the user is in Cycle / general wellness mode (not pregnancy mode).

CRITICAL response rules:
1. Answer ONLY what the user asked. Stay strictly on their topic.
2. Never mention PCOS unless the user explicitly asked about PCOS.
3. For greetings / thanks / bye: reply in 1–2 friendly sentences only. No tips, no topic pitching.
4. Unrelated questions: answer briefly and kindly, or say you mainly help with women's wellness.
5. Be concise and specific. Prefer direct answers over generic wellness essays.
6. Add a short medical disclaimer only when giving health advice — never for greetings/chitchat.
7. Never invent personal medical diagnoses.
''';

  static const String _pregnancySystemPrompt = '''
You are HerCycle Bloom AI — a warm, reassuring pregnancy companion.

Context: the user is in Pregnancy mode.

CRITICAL response rules:
1. Answer ONLY what the user asked. Stay strictly on their topic.
2. Never bring up PCOS unless they ask.
3. For greetings / thanks / bye: reply in 1–2 friendly sentences only. No tips, no topic pitching.
4. Focus on pregnancy-safe guidance when the question is health-related.
5. Be concise and specific. Prefer direct answers over generic essays.
6. Add a short medical disclaimer only when giving health advice — never for greetings/chitchat.
7. Never invent personal medical diagnoses.
''';

  Future<String> getResponse(
    String prompt, {
    List<Content>? history,
    AiContextMode mode = AiContextMode.cycle,
    int? pregnancyWeek,
  }) async {
    final key = AppConfig.geminiApiKey;
    if (key.isEmpty || key == 'YOUR_GEMINI_API_KEY') {
      return 'AI_NOT_CONFIGURED';
    }

    final systemPrompt = _buildSystemPrompt(mode, pregnancyWeek: pregnancyWeek);
    final sanitized = _sanitizeHistory(history);
    Object? lastError;

    for (final modelName in _modelCandidates) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: key,
          systemInstruction: Content.system(systemPrompt),
        );
        final chat = model.startChat(history: sanitized);
        final response = await chat.sendMessage(Content.text(prompt));
        final text = response.text?.trim();
        if (text == null || text.isEmpty) {
          return "I couldn't generate a response right now. Please try rephrasing your question.";
        }
        return text;
      } catch (e) {
        lastError = e;
        debugPrint('Gemini model "$modelName" failed: $e');
        final msg = e.toString().toLowerCase();
        final tryNext = msg.contains('not found') ||
            msg.contains('404') ||
            msg.contains('unsupported') ||
            msg.contains('is not found');
        if (!tryNext) break;
      }
    }

    // Retry once with no history if history caused the failure
    if (sanitized.isNotEmpty && lastError != null) {
      try {
        final model = GenerativeModel(
          model: _modelCandidates.first,
          apiKey: key,
          systemInstruction: Content.system(systemPrompt),
        );
        final chat = model.startChat();
        final response = await chat.sendMessage(Content.text(prompt));
        final text = response.text?.trim();
        if (text != null && text.isNotEmpty) return text;
      } catch (e) {
        lastError = e;
        debugPrint('Gemini no-history retry failed: $e');
      }
    }

    return _handleError(lastError ?? 'unknown');
  }

  Future<String> analyzeImage(
    Uint8List imageBytes,
    String prompt, {
    AiContextMode mode = AiContextMode.cycle,
  }) async {
    if (AppConfig.geminiApiKey.isEmpty ||
        AppConfig.geminiApiKey == 'YOUR_GEMINI_API_KEY') {
      return 'AI_NOT_CONFIGURED';
    }

    final systemPrompt = _buildSystemPrompt(mode);
    Object? lastError;

    for (final modelName in _modelCandidates) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: AppConfig.geminiApiKey,
          systemInstruction: Content.system(systemPrompt),
        );
        final content = [
          Content.multi([
            TextPart(prompt),
            DataPart('image/jpeg', imageBytes),
          ])
        ];
        final response = await model.generateContent(content);
        return response.text ?? 'Unable to analyze image.';
      } catch (e) {
        lastError = e;
        debugPrint('Gemini image model "$modelName" failed: $e');
        final msg = e.toString().toLowerCase();
        if (!(msg.contains('not found') || msg.contains('404'))) break;
      }
    }

    return _handleError(lastError ?? 'unknown');
  }

  String _buildSystemPrompt(AiContextMode mode, {int? pregnancyWeek}) {
    if (mode == AiContextMode.pregnancy) {
      final weekNote = pregnancyWeek != null
          ? '\n\nUser context: Currently at pregnancy week $pregnancyWeek.'
          : '';
      return _pregnancySystemPrompt + weekNote;
    }
    return _cycleSystemPrompt;
  }

  List<Content> _sanitizeHistory(List<Content>? history) {
    if (history == null || history.isEmpty) return const [];

    final cleaned = <Content>[];
    for (final item in history) {
      final role = item.role;
      if (role != 'user' && role != 'model') continue;
      if (cleaned.isNotEmpty && cleaned.last.role == role) {
        cleaned.removeLast();
      }
      cleaned.add(item);
    }

    while (cleaned.isNotEmpty && cleaned.first.role != 'user') {
      cleaned.removeAt(0);
    }

    if (cleaned.length > 10) {
      return cleaned.sublist(cleaned.length - 10);
    }
    return cleaned;
  }

  String _handleError(dynamic e) {
    final errorStr = e.toString().toLowerCase();
    debugPrint('AIService final error: $e');

    if (errorStr.contains('socketexception') ||
        errorStr.contains('host lookup') ||
        errorStr.contains('failed to connect') ||
        errorStr.contains('network')) {
      return 'Unable to connect. Please check your internet connection and try again.';
    }

    if (errorStr.contains('quota') ||
        errorStr.contains('429') ||
        errorStr.contains('rate limit') ||
        errorStr.contains('resource_exhausted')) {
      return 'HerCycle Bloom is currently handling a lot of requests. Please try again in a few minutes.';
    }

    if (errorStr.contains('invalid api key') ||
        errorStr.contains('api key not valid') ||
        errorStr.contains('api_key_invalid') ||
        errorStr.contains('permission_denied')) {
      return 'There is an issue with the AI configuration. Please contact support.';
    }

    if (errorStr.contains('not found') || errorStr.contains('404')) {
      return 'The AI model is temporarily unavailable. Please try again shortly.';
    }

    return "I'm having trouble reaching the AI coach right now. Please try again in a moment.";
  }
}
