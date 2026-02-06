import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:moving_tool_flutter/core/services/ai/ai_service.dart';

class GeminiService implements AIService {
  GeminiService(String apiKey)
    : _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      ); // Use 1.5 flash for vision
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

  @override
  Future<String?> generateContentFromImage(String prompt, File image) async {
    try {
      final imageBytes = await image.readAsBytes();
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart(
            'image/jpeg',
            imageBytes,
          ), // Assumption: image is jpeg or convertable
        ]),
      ];

      final response = await _model.generateContent(content);
      return response.text;
    } catch (e) {
      debugPrint('Gemini Vision Error: $e');
      return null;
    }
  }
}
