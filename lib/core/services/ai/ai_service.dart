import 'dart:io';

abstract class AIService {
  /// Generates text content based on the provided prompt/input.
  Future<String?> generateContent(String prompt);

  /// Generates text content based on the provided prompt and image.
  Future<String?> generateContentFromImage(String prompt, File image);
}
