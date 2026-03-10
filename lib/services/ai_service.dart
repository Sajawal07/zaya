import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/app_config.dart';

class AIService {
  late GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: AppConfig.geminiApiKey,
    );
  }

  Future<String> getResponse(String prompt, {List<Content>? history}) async {
    if (AppConfig.geminiApiKey == 'YOUR_GEMINI_API_KEY') {
      return "Zaya AI is almost ready! Please add your Gemini API key in `lib/core/app_config.dart` to start chatting with me.";
    }

    try {
      final chat = _model.startChat(history: history);
      final response = await chat.sendMessage(Content.text(prompt));
      return response.text ?? "I'm sorry, I couldn't process that.";
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<String> analyzeImage(Uint8List imageBytes, String prompt) async {
    if (AppConfig.geminiApiKey == 'YOUR_GEMINI_API_KEY') {
       return "Zaya AI is almost ready!";
    }

    try {
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      return response.text ?? "Unable to analyze image.";
    } catch (e) {
      return _handleError(e);
    }
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
      return "Zaya is currently handling a lot of requests. Please try again in a few minutes, or wait until your daily limit resets.";
    }

    if (errorStr.contains('invalid api key')) {
      return "There is an issue with the AI configuration. Please contact support.";
    }

    return "I'm sorry, I'm having trouble processing that right now. Please try again in a moment.";
  }
}
