import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

/// Service for LLM-powered features with local fallback support
class LlmService {
  static const String _geminiModel = 'gemini-2.0-flash';

  // Ollama runs locally - no internet needed
  static const String _ollamaUrl = 'http://localhost:11434/api/generate';
  static const String _ollamaModel = 'llama3.2'; // or 'mistral', 'phi3'

  /// Generates a packing list for a specific room type
  static Future<String> suggestPackingList(
    String roomType,
    String? geminiApiKey,
  ) async {
    final prompt =
        'Maak een checklist van 5-10 essentiële items om in te pakken voor een: $roomType. Geef alleen de lijst met bullets.';
    return await _generateContent(prompt, geminiApiKey);
  }

  /// Generates moving advice based on days remaining
  static Future<String> getMovingAdvice(
    int daysLeft,
    String? geminiApiKey,
  ) async {
    final prompt =
        'Ik ga verhuizen over $daysLeft dagen. Geef me 3 cruciale tips waar ik NU aan moet denken. Hou het kort en krachtig.';
    return await _generateContent(prompt, geminiApiKey);
  }

  static Future<String> _generateContent(
    String prompt,
    String? geminiApiKey,
  ) async {
    // Try Gemini first
    if (geminiApiKey != null && geminiApiKey.isNotEmpty) {
      try {
        final result = await _tryGemini(prompt, geminiApiKey);
        if (result != null) return result;
      } catch (e) {
        debugPrint('Gemini failed: $e');
      }
    }

    // Fallback to Ollama
    try {
      final result = await _tryOllama(prompt);
      if (result != null) return result;
    } catch (e) {
      debugPrint('Ollama failed: $e');
    }

    return 'Kon geen AI suggestie genereren. Controleer je internet of Gemini quotum. Of start Ollama lokaal.';
  }

  /// Summarizes the project overview using available LLM
  /// Falls back to local Ollama if Gemini fails
  static Future<String> summarizeOverview(
    String markdownContent,
    String? geminiApiKey,
  ) async {
    // Try Gemini first if API key is available
    if (geminiApiKey != null && geminiApiKey.isNotEmpty) {
      try {
        final result = await _tryGemini(markdownContent, geminiApiKey);
        if (result != null) return result;
      } catch (e) {
        debugPrint('Gemini failed, trying local Ollama: $e');
      }
    }

    // Fallback to local Ollama (no internet/API key needed)
    try {
      final result = await _tryOllama(markdownContent);
      if (result != null) return result;
    } catch (e) {
      debugPrint('Ollama fallback failed: $e');
    }

    // If all else fails, return a helpful message
    return '''_Kon geen AI samenvatting genereren._

**Opties:**
1. **Wacht** tot je Gemini quotum reset (±1 min)
2. **Installeer Ollama** voor lokale AI (geen internet nodig):
   - Download: ollama.com
   - Run: `ollama pull llama3.2`
   - Start: `ollama serve`

Je kunt het Ultiem Overzicht nog steeds zonder AI exporteren!''';
  }

  static Future<String?> _tryGemini(String content, String apiKey) async {
    final model = GenerativeModel(model: _geminiModel, apiKey: apiKey);

    final prompt = _buildPrompt(content);
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text;
  }

  static Future<String?> _tryOllama(String content) async {
    // Truncate content for smaller local models
    final truncatedContent = content.length > 4000
        ? '${content.substring(0, 4000)}...\n[Inhoud ingekort]'
        : content;

    final prompt =
        '''Je bent een slimme assistent voor een verhuisapp. Analyseer dit verhuisoverzicht en geef een beknopte Nederlandse samenvatting.

Focus op:
- Belangrijkste actiepunten die nog moeten gebeuren
- Voortgang (wat gaat goed, wat loopt achter)
- Knelpunten of problemen
- Prioriteiten voor de komende dagen

Verhuisoverzicht:
$truncatedContent

Geef nu een duidelijke samenvatting:''';

    try {
      final response = await http
          .post(
            Uri.parse(_ollamaUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': _ollamaModel,
              'prompt': prompt,
              'stream': false,
              'options': {'temperature': 0.7, 'num_predict': 800},
            }),
          )
          .timeout(const Duration(seconds: 120)); // Local models can be slow

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['response'] as String?;
      }

      debugPrint('Ollama response: ${response.statusCode}');
    } catch (e) {
      debugPrint('Ollama connection error: $e');
    }

    return null;
  }

  static String _buildPrompt(String content) {
    return '''
Je bent een slimme assistent voor een verhuisapp. Analyseer het volgende verhuisoverzicht en stel een uitgebreid rapport op.

Het rapport moet behandelen:
- **Actiepunten**: Wat moet er nog gebeuren
- **Voortgang**: Huidige stand van zaken
- **Knelpunten**: Mogelijke problemen of vertragingen
- **Prioriteiten**: Hoogste prioriteit komende tijd
- **Conclusie**: Algemene observaties

Gebruik koppen en bullets. Schrijf in het Nederlands.

---

$content

---

Rapport:
''';
  }
}
