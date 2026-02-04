import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:moving_tool_flutter/core/services/ai/ai_service.dart';

class GeminiService implements AIService {

  GeminiService(String apiKey)
    : _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  final GenerativeModel _model;

  @override
  Future<String?> generateContent(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      debugPrint('Gemini Error: $e');
      return null;
    }
  }
}
