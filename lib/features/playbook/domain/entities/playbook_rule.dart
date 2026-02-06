enum EventTrigger { expenseAdded, taskCompleted, memberJoined, projectCreated }

enum ActionType { createTask, sendNotification, logEvent }

class PlaybookAction {
  final ActionType type;
  final Map<String, dynamic> payload;

  const PlaybookAction({required this.type, required this.payload});
}

class PlaybookRule {
  final String id;
  final String blueprintId; // Which blueprint this rule belongs to
  final EventTrigger trigger;
  final String? condition; // Simple logic string, e.g., "amount > 50"
  final PlaybookAction action;

  const PlaybookRule({
    required this.id,
    required this.blueprintId,
    required this.trigger,
    this.condition,
    required this.action,
  });
}
