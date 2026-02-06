import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moving_tool_flutter/data/providers/ai_providers.dart';
import 'package:moving_tool_flutter/features/projects/application/transport_advisor_service.dart';

final transportAdvisorProvider = Provider<TransportAdvisorService>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return TransportAdvisorService(aiService: aiService);
});
