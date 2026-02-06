// Receipt Data Model - Parsed receipt structure
import 'package:flutter/foundation.dart';

/// Represents extracted data from a scanned receipt
@immutable
class ReceiptData {
  const ReceiptData({
    this.storeName,
    this.date,
    this.totalAmount,
    this.items = const [],
    this.rawText = '',
    this.confidence = 0.0,
  });

  /// Create from raw OCR text with smart parsing
  factory ReceiptData.fromRawText(String text) {
    return _ReceiptParser.parse(text);
  }

  final String? storeName;
  final DateTime? date;
  final double? totalAmount;
  final List<ReceiptItem> items;
  final String rawText;
  final double confidence; // 0.0 - 1.0

  ReceiptData copyWith({
    String? storeName,
    DateTime? date,
    double? totalAmount,
    List<ReceiptItem>? items,
    String? rawText,
    double? confidence,
  }) {
    return ReceiptData(
      storeName: storeName ?? this.storeName,
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      items: items ?? this.items,
      rawText: rawText ?? this.rawText,
      confidence: confidence ?? this.confidence,
    );
  }

  bool get isEmpty => storeName == null && totalAmount == null && items.isEmpty;
  bool get hasMinimumData => storeName != null || totalAmount != null;
}

/// Individual item on receipt
@immutable
class ReceiptItem {
  const ReceiptItem({required this.name, this.price, this.quantity = 1});

  final String name;
  final double? price;
  final int quantity;
}

/// Internal parser for receipt text
class _ReceiptParser {
  static ReceiptData parse(String text) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();

    String? storeName;
    DateTime? date;
    double? totalAmount;
    final items = <ReceiptItem>[];
    double confidence = 0.0;

    // Store name: Usually first non-empty line
    if (lines.isNotEmpty) {
      storeName = _cleanStoreName(lines.first);
      confidence += 0.2;
    }

    // Find date
    date = _findDate(text);
    if (date != null) confidence += 0.2;

    // Find total amount
    totalAmount = _findTotal(text);
    if (totalAmount != null) confidence += 0.3;

    // Find line items with prices
    items.addAll(_findItems(lines));
    if (items.isNotEmpty) confidence += 0.3;

    return ReceiptData(
      storeName: storeName,
      date: date,
      totalAmount: totalAmount,
      items: items,
      rawText: text,
      confidence: confidence.clamp(0.0, 1.0),
    );
  }

  static String _cleanStoreName(String line) {
    // Remove common prefixes and clean up
    return line
        .replaceAll(RegExp(r"[^\w\s&'-]"), '')
        .trim()
        .split(RegExp(r'\s{2,}'))
        .first;
  }

  static DateTime? _findDate(String text) {
    // Common date patterns
    final patterns = [
      // DD-MM-YYYY or DD/MM/YYYY
      RegExp(r'(\d{1,2})[-/](\d{1,2})[-/](\d{4})'),
      // DD-MM-YY or DD/MM/YY
      RegExp(r'(\d{1,2})[-/](\d{1,2})[-/](\d{2})'),
      // YYYY-MM-DD
      RegExp(r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          int day, month, year;
          if (pattern.pattern.startsWith(r'(\d{4})')) {
            // YYYY-MM-DD format
            year = int.parse(match.group(1)!);
            month = int.parse(match.group(2)!);
            day = int.parse(match.group(3)!);
          } else {
            // DD-MM-YYYY or DD-MM-YY format
            day = int.parse(match.group(1)!);
            month = int.parse(match.group(2)!);
            year = int.parse(match.group(3)!);
            if (year < 100) year += 2000;
          }
          return DateTime(year, month, day);
        } catch (_) {
          continue;
        }
      }
    }
    return null;
  }

  static double? _findTotal(String text) {
    // Look for TOTAL, TOTAAL, SUBTOTAL patterns with price
    final patterns = [
      RegExp(
        r'(?:TOTAL|TOTAAL|BEDRAG|SUBTOTAL)[:\s]*[€£$]?\s*(\d+[.,]\d{2})',
        caseSensitive: false,
      ),
      RegExp(
        r'[€£$]\s*(\d+[.,]\d{2})\s*(?:TOTAL|TOTAAL)',
        caseSensitive: false,
      ),
      // Largest price on receipt often is total
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final priceStr = match.group(1)?.replaceAll(',', '.');
        if (priceStr != null) {
          return double.tryParse(priceStr);
        }
      }
    }

    // Fallback: find largest price
    final allPrices = RegExp(r'[€£$]?\s*(\d+[.,]\d{2})')
        .allMatches(text)
        .map(
          (m) => double.tryParse(m.group(1)?.replaceAll(',', '.') ?? '') ?? 0,
        )
        .where((p) => p > 0)
        .toList();

    if (allPrices.isNotEmpty) {
      allPrices.sort((a, b) => b.compareTo(a));
      return allPrices.first;
    }

    return null;
  }

  static List<ReceiptItem> _findItems(List<String> lines) {
    final items = <ReceiptItem>[];
    final pricePattern = RegExp(r'[€£$]?\s*(\d+[.,]\d{2})');

    for (final line in lines) {
      final match = pricePattern.firstMatch(line);
      if (match != null) {
        final priceStr = match.group(1)?.replaceAll(',', '.');
        final price = double.tryParse(priceStr ?? '');

        // Extract name (text before price)
        var name = line.substring(0, match.start).trim();

        // Clean up name
        name = name.replaceAll(
          RegExp(r'^\d+\s*[xX]\s*'),
          '',
        ); // Remove quantity prefix
        name = name.replaceAll(RegExp(r"[^\w\s'-]"), '').trim();

        if (name.length >= 2 && price != null && price > 0 && price < 10000) {
          items.add(ReceiptItem(name: name, price: price));
        }
      }
    }

    return items;
  }
}
