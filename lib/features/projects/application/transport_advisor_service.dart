import 'package:moving_tool_flutter/core/services/ai/ai_service.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/packing_box.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/transport_resource.dart';

class TransportAdvisorService {
  final AIService? aiService;

  TransportAdvisorService({this.aiService});

  // Rough estimates in cubic meters
  static const double _boxVolume = 0.06; // Standard moving box ~60L

  Future<double> estimateItemVolume(String itemDescription) async {
    if (aiService == null)
      return 0.5; // Default conservative estimate for unknown item

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

  /// Returns a list of advice strings based on the project's payload vs. capacity.
  List<String> analyzeTransport({
    required Project project,
    required List<PackingBox> boxes,
  }) {
    final advice = <String>[];

    // 1. Calculate Total Volume
    final totalBoxVolume = boxes.length * _boxVolume;
    // TODO: Add furniture volume estimation here (AI or manual list)
    final totalVolume = totalBoxVolume;

    // 2. Calculate Available Capacity
    double totalCapacity = 0.0;
    for (final resource in project.resources) {
      totalCapacity += getCapacityInM3(resource.capacity);
    }

    advice.add(
      'Estimated Total Volume: ${totalVolume.toStringAsFixed(1)} m³ (${boxes.length} boxes)',
    );
    advice.add(
      'Available Transport Capacity: ${totalCapacity.toStringAsFixed(1)} m³',
    );

    // 3. Compare and Advise
    if (totalCapacity < totalVolume) {
      final deficit = totalVolume - totalCapacity;
      advice.add(
        'WARNING: You are short by ${deficit.toStringAsFixed(1)} m³ capacity!',
      );
      advice.add('Consider renting a larger vehicle or making multiple trips.');

      // Simple trip calculation
      if (totalCapacity > 0) {
        final trips = (totalVolume / totalCapacity).ceil();
        advice.add(
          'With current resources, you need approximately $trips trips.',
        );
      }
    } else {
      final usage = (totalVolume / totalCapacity) * 100;
      advice.add(
        'Excellent! You have enough capacity (Using ~${usage.toStringAsFixed(0)}%).',
      );
    }

    return advice;
  }
}
