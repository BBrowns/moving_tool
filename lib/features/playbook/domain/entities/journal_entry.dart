enum JournalEventType {
  taskCompleted,
  boxPacked,
  itemPurchased,
  expenseAdded,
  milestone,
  note,
  custom,
}

extension JournalEventTypeExtension on JournalEventType {
  String get icon {
    switch (this) {
      case JournalEventType.taskCompleted:
        return '✅';
      case JournalEventType.boxPacked:
        return '📦';
      case JournalEventType.itemPurchased:
        return '🛍️';
      case JournalEventType.expenseAdded:
        return '💰';
      case JournalEventType.milestone:
        return '🎯';
      case JournalEventType.note:
        return '📝';
      case JournalEventType.custom:
        return '📌';
    }
  }

  String get label {
    switch (this) {
      case JournalEventType.taskCompleted:
        return 'Taak afgerond';
      case JournalEventType.boxPacked:
        return 'Doos ingepakt';
      case JournalEventType.itemPurchased:
        return 'Item gekocht';
      case JournalEventType.expenseAdded:
        return 'Uitgave toegevoegd';
      case JournalEventType.milestone:
        return 'Mijlpaal';
      case JournalEventType.note:
        return 'Notitie';
      case JournalEventType.custom:
        return 'Gebeurtenis';
    }
  }
}

class JournalEntry {
  final String id;
  final JournalEventType type;
  final String title;
  final String? description;
  final String? userId;
  final String? relatedEntityId;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  JournalEntry({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.userId,
    this.relatedEntityId,
    this.metadata,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'userId': userId,
      'relatedEntityId': relatedEntityId,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
