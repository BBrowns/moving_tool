import 'package:flutter/material.dart';

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
  IconData get icon {
    switch (this) {
      case JournalEventType.taskCompleted:
        return Icons.check_circle_rounded;
      case JournalEventType.boxPacked:
        return Icons.inventory_2_rounded;
      case JournalEventType.itemPurchased:
        return Icons.shopping_bag_rounded;
      case JournalEventType.expenseAdded:
        return Icons.euro_rounded;
      case JournalEventType.milestone:
        return Icons.flag_rounded;
      case JournalEventType.note:
        return Icons.note_alt_rounded;
      case JournalEventType.custom:
        return Icons.push_pin_rounded;
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
