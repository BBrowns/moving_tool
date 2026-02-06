// OCR Service - Google ML Kit Text Recognition wrapper
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:moving_tool_flutter/features/receipt_scanner/domain/models/receipt_data.dart';

/// Service for extracting text from images using on-device ML Kit
class OcrService {
  OcrService._();
  static final instance = OcrService._();

  TextRecognizer? _textRecognizer;

  /// Initialize the text recognizer
  void initialize() {
    _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
  }

  /// Dispose of resources
  Future<void> dispose() async {
    await _textRecognizer?.close();
    _textRecognizer = null;
  }

  /// Extract raw text from an image file
  Future<String> extractText(File imageFile) async {
    initialize();

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer!.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      debugPrint('OCR Error: $e');
      rethrow;
    }
  }

  /// Extract and parse receipt data from an image
  Future<ReceiptData> scanReceipt(File imageFile) async {
    final rawText = await extractText(imageFile);
    return ReceiptData.fromRawText(rawText);
  }

  /// Get structured text blocks with positioning
  Future<RecognizedText> getTextBlocks(File imageFile) async {
    initialize();

    final inputImage = InputImage.fromFile(imageFile);
    return await _textRecognizer!.processImage(inputImage);
  }

  /// Extract all prices found in text
  List<double> extractPrices(String text) {
    final pricePattern = RegExp(r'[€£$]?\s*(\d+[.,]\d{2})');
    return pricePattern
        .allMatches(text)
        .map(
          (m) => double.tryParse(m.group(1)?.replaceAll(',', '.') ?? '') ?? 0,
        )
        .where((p) => p > 0)
        .toList();
  }
}
