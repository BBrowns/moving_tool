import 'package:moving_tool_flutter/features/playbook/domain/entities/playbook_rule.dart';

class Blueprints {
  static final List<PlaybookRule> standardRules = [
    // Example Rule: When a high expense is added, notify
    const PlaybookRule(
      id: 'rule_high_expense',
      blueprintId: 'standard_move',
      trigger: EventTrigger.expenseAdded,
      condition: 'amount > 500',
      action: PlaybookAction(
        type: ActionType.sendNotification,
        payload: {'message': 'High expense detected! Review required.'},
      ),
    ),
    // Example Rule: When project created, create initial tasks
    const PlaybookRule(
      id: 'rule_init_tasks',
      blueprintId: 'standard_move',
      trigger: EventTrigger.projectCreated,
      action: PlaybookAction(
        type: ActionType.createTask,
        payload: {'title': 'Order Moving Boxes', 'category': 'packing'},
      ),
    ),
  ];

  static List<PlaybookRule> getRulesForBlueprint(String blueprintId) {
    return standardRules.where((r) => r.blueprintId == blueprintId).toList();
  }
}
