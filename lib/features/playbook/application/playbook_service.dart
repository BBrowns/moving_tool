import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moving_tool_flutter/features/playbook/data/blueprints.dart';
import 'package:moving_tool_flutter/features/playbook/domain/entities/playbook_rule.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';

// Forward declaration or import for TaskNotifier if possible,
// but circular dependency risk is high if TaskNotifier depends on PlaybookService.
// Standard pattern: Notifiers call PlaybookService. PlaybookService calls specific UseCases or Repositories.
// For MVP, we might implement simple print/log actions or use a ref.read to get other notifiers.

class PlaybookService {
  final Ref ref;

  PlaybookService(this.ref);

  Future<void> handleEvent({
    required EventTrigger trigger,
    required Project project,
    Map<String, dynamic> context = const {},
  }) async {
    debugPrint(
      '[Playbook] Event: ${trigger.name} for project ${project.name} (${project.blueprintId})',
    );

    // 1. Get Rules for this Blueprint
    final rules = Blueprints.getRulesForBlueprint(project.blueprintId);

    // 2. Filter matching triggers
    final matchingRules = rules.where((r) => r.trigger == trigger);

    for (final rule in matchingRules) {
      if (_evaluateCondition(rule.condition, context)) {
        await _executeAction(rule.action, project);
      }
    }
  }

  bool _evaluateCondition(String? condition, Map<String, dynamic> context) {
    if (condition == null || condition.isEmpty) return true;

    // Very simple evaluator for MVP
    // Supports: "amount > X"
    if (condition.startsWith('amount >')) {
      final val = double.tryParse(condition.split('>')[1].trim()) ?? 0;
      final amount = (context['amount'] as num?)?.toDouble() ?? 0;
      return amount > val;
    }

    return true; // Default to true if unknown condition format (or implement better parser)
  }

  Future<void> _executeAction(PlaybookAction action, Project project) async {
    debugPrint('[Playbook] Executing Action: ${action.type.name}');

    switch (action.type) {
      case ActionType.logEvent:
        print('[LOG] ${action.payload}');
        break;
      case ActionType.sendNotification:
        // TODO: Integage with NotificationService
        print('[NOTIF] ${action.payload['message']}');
        break;
      case ActionType.createTask:
        // TODO: Integrate with TaskNotifier or TaskRepository
        // Since we are in the service layer, we might want to use the Repository directly
        // or a callback.
        print('[TASK] Create task: ${action.payload['title']}');
        break;
    }
  }
}

final playbookServiceProvider = Provider<PlaybookService>((ref) {
  return PlaybookService(ref);
});
