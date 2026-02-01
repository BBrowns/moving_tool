// Domain Models - Playbook (simplified, no Hive)
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
}

class PlaybookNote {
  final String id;
  final String title;
  final String content;
  final String? category;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlaybookNote({
    required this.id,
    required this.title,
    required this.content,
    this.category,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  PlaybookNote copyWith({
    String? title,
    String? content,
    String? category,
    bool? isPinned,
    DateTime? updatedAt,
  }) {
    return PlaybookNote(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
