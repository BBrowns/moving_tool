import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moving_tool_flutter/core/services/ai/ai_service.dart';
import 'package:moving_tool_flutter/data/services/ai/gemini_service.dart';
import 'package:moving_tool_flutter/data/services/database_service.dart';

final aiServiceProvider = Provider<AIService>((ref) {
  // Retrieve API key from settings
  final apiKey = DatabaseService.getSetting('gemini_api_key') ?? '';
  return GeminiService(apiKey);
});
