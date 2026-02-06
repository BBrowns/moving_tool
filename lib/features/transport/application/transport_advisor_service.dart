import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:moving_tool_flutter/core/models/item_dimensions.dart';
import 'package:moving_tool_flutter/core/services/ai/ai_service.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/packing_box.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/transport_resource.dart';

class TransportAdvisorService {
  final AIService? aiService;

  TransportAdvisorService({this.aiService});

  // Rough estimates in cubic meters

  // Rough estimates in cubic meters
  static const double _boxVolume = 0.06; // Standard moving box ~60L

  /// Approximate inner dimensions (LxWxH in cm) for capacity types
  static const Map<TransportCapacity, ItemDimensions> _vehicleDimensions = {
    TransportCapacity.small: ItemDimensions(
      heightCm: 80,
      widthCm: 100,
      depthCm: 120, // Car trunk
    ),
    TransportCapacity.medium: ItemDimensions(
      heightCm: 140,
      widthCm: 160,
      depthCm: 250, // Small Van
    ),
    TransportCapacity.large: ItemDimensions(
      heightCm: 190,
      widthCm: 180,
      depthCm: 320, // Large Van
    ),
    TransportCapacity.extraLarge: ItemDimensions(
      heightCm: 220,
      widthCm: 220,
      depthCm: 450, // Box Truck
    ),
  };

  /// Estimates dimensions from a photo using AI Vision
  Future<ItemDimensions?> estimateDimensionsFromImage(File image) async {
    if (aiService == null) {
      throw Exception('AI Service not initialized. Check API Key.');
    }

    final prompt = '''
Analyze this image of a furniture item/object.
Estimate the Height, Width, and Depth in centimeters.
Also estimate the weight in kg.
Format response as JSON: {"height": 100, "width": 50, "depth": 50, "weight": 20}
Return ONLY the JSON. Do not include markdown formatting like ```json.
''';

    try {
      final response = await aiService!.generateContentFromImage(prompt, image);
      if (response == null) throw Exception('AI returned no response.');

      // Clean up markdown if AI ignores instructions
      final jsonStr = response
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // Basic parsing using RegExp for robustness against malformed JSON structure
      final height = _extractVal(jsonStr, 'height');
      final width = _extractVal(jsonStr, 'width');
      final depth = _extractVal(jsonStr, 'depth');
      final weight = _extractVal(jsonStr, 'weight');

      if (height == null || width == null || depth == null) {
        throw Exception('Failed to extract dimensions from AI response.');
      }

      return ItemDimensions(
        heightCm: height,
        widthCm: width,
        depthCm: depth,
        weightKg: weight,
      );
    } catch (e) {
      debugPrint('Error parsing dimensions: $e');
      rethrow; // Let the UI handle the specific error
    }
  }

  double? _extractVal(String text, String key) {
    // Regex matches "key": 123 or "key": 123.45, case-insensitive
    final regex = RegExp('"$key"\\s*:\\s*([0-9.]+)', caseSensitive: false);
    final match = regex.firstMatch(text);
    return match != null ? double.tryParse(match.group(1)!) : null;
  }

  Future<double> estimateItemVolume(String itemDescription) async {
    if (aiService == null) {
      return 0.5; // Fallback for unknown
    }

    final prompt =
        'Estimate the volume in cubic meters (m3) for: "$itemDescription". Return ONLY the estimated number, e.g. "0.4". Do not add text.';
    final response = await aiService!.generateContent(prompt);
    if (response == null) return 0.5;

    try {
      final cleaned = response.replaceAll(RegExp(r'[^\d.]'), '');
      return double.parse(cleaned);
    } catch (e) {
      return 0.5;
    }
  }

  static double getCapacityInM3(TransportCapacity capacity) {
    switch (capacity) {
      case TransportCapacity.small:
        return 2.0; // Large car / small trailer
      case TransportCapacity.medium:
        return 6.0; // Van
      case TransportCapacity.large:
        return 18.0; // Small truck
      case TransportCapacity.extraLarge:
        return 40.0; // Large truck
    }
  }

  /// Checks if a single large item fits physically in a resource
  /// Returns a reason string if it doesn't fit, or null if it fits
  String? checkPhysicalFit(ItemDimensions item, TransportResource resource) {
    final vehicleDims = _vehicleDimensions[resource.capacity];
    if (vehicleDims == null) {
      return null; // Unknown dimensions, assume fit based on volume
    }

    // Check if item is too large in any SINGLE dimension (assuming rotation)
    // We sort dimensions to find best fit (greedy orientation)
    final iDims = [item.heightCm!, item.widthCm!, item.depthCm!]..sort();
    final vDims = [
      vehicleDims.heightCm!,
      vehicleDims.widthCm!,
      vehicleDims.depthCm!,
    ]..sort();

    // If smallest item dim > smallest vehicle dim? No, actually,
    // we need to see if there's SOME orientation where it fits.
    // If we sort both ascending, then i[0] must <= v[0], i[1] <= v[1], etc.
    // This is a necessary condition for orthogonal packing.

    if (iDims[0] > vDims[0]) {
      return 'Item too thick (${iDims[0]}cm > ${vDims[0]}cm)';
    }
    if (iDims[1] > vDims[1]) {
      return 'Item too wide (${iDims[1]}cm > ${vDims[1]}cm)';
    }
    if (iDims[2] > vDims[2]) {
      return 'Item too long (${iDims[2]}cm > ${vDims[2]}cm)';
    }

    return null; // Fits physically
  }

  /// Returns a list of advice strings based on the project's payload vs. capacity.
  List<String> analyzeTransport({
    required Project project,
    required List<PackingBox> boxes,
    List<ItemDimensions>? largeItems, // New: support for furniture dims
  }) {
    final advice = <String>[];

    // 1. Calculate Total Volume
    final totalBoxVolume = boxes.length * _boxVolume;
    double furnitureVolume = 0.0;

    if (largeItems != null) {
      for (final item in largeItems) {
        furnitureVolume += item.volumeM3;
      }
    }

    final totalVolume = totalBoxVolume + furnitureVolume;

    // 2. Calculate Available Capacity
    double totalCapacity = 0.0;
    for (final resource in project.resources) {
      totalCapacity += getCapacityInM3(resource.capacity);
    }

    advice.add(
      'Total Load: ${totalVolume.toStringAsFixed(1)} m³ (${boxes.length} boxes + ${largeItems?.length ?? 0} items)',
    );
    advice.add('Fleet Capacity: ${totalCapacity.toStringAsFixed(1)} m³');

    // 3. Physical Fit Checks (Warning only)
    if (largeItems != null && project.resources.isNotEmpty) {
      // Check largest item against largest vehicle
      // This is a simplification: we just warn if ANY item implies a larger vehicle is needed
      // Find largest vehicle
      final bestVehicle = project.resources.reduce(
        (a, b) =>
            getCapacityInM3(a.capacity) > getCapacityInM3(b.capacity) ? a : b,
      );

      for (final item in largeItems) {
        if (item.isComplete) {
          final fitIssue = checkPhysicalFit(item, bestVehicle);
          if (fitIssue != null) {
            advice.add(
              '⚠️ PHYSICAL FIT WARNING: An item is likely too big for your largest vehicle (${bestVehicle.name}). Issue: $fitIssue',
            );
          }
        }
      }
    }

    // 4. Volume Fit
    if (totalCapacity < totalVolume) {
      final deficit = totalVolume - totalCapacity;
      advice.add(
        'WARNING: Volume deficit of ${deficit.toStringAsFixed(1)} m³!',
      );

      // Simple trip calculation
      if (totalCapacity > 0) {
        final trips = (totalVolume / totalCapacity).ceil();
        advice.add(
          'Estimate: You need approx. $trips trips with current fleet.',
        );
      }
    } else {
      final usage = (totalVolume / totalCapacity) * 100;
      advice.add(
        'Volume OK (Using ~${usage.toStringAsFixed(0)}% of capacity).',
      );
    }

    return advice;
  }
}
