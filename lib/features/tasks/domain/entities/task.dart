import 'package:flutter/material.dart';

// Domain Models - Task (simplified, no Hive annotations)
enum TaskCategory {
  administratie,
  klussen,
  inkopen,
  schoonmaken,
  verhuizing,
  overig,
}

enum TaskStatus { todo, inProgress, done }

extension TaskCategoryExtension on TaskCategory {
  String get label {
    switch (this) {
      case TaskCategory.administratie:
        return 'Administratie';
      case TaskCategory.klussen:
        return 'Klussen';
      case TaskCategory.inkopen:
        return 'Inkopen';
      case TaskCategory.schoonmaken:
        return 'Schoonmaken';
      case TaskCategory.verhuizing:
        return 'Verhuizing';
      case TaskCategory.overig:
        return 'Overig';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskCategory.administratie:
        return Icons.receipt_long_rounded;
      case TaskCategory.klussen:
        return Icons.build_rounded;
      case TaskCategory.inkopen:
        return Icons.shopping_cart_rounded;
      case TaskCategory.schoonmaken:
        return Icons.cleaning_services_rounded;
      case TaskCategory.verhuizing:
        return Icons.local_shipping_rounded;
      case TaskCategory.overig:
        return Icons.push_pin_rounded;
    }
  }
}

extension TaskStatusExtension on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'Te doen';
      case TaskStatus.inProgress:
        return 'Bezig';
      case TaskStatus.done:
        return 'Klaar';
    }
  }
}

class Task {
  Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.category,
    required this.createdAt,
    this.description = '',
    this.status = TaskStatus.todo,
    this.assigneeId,
    this.deadline,
  });
  final String id;
  final String projectId;
  final String title;
  final String description;
  final TaskCategory category;
  final TaskStatus status;
  final String? assigneeId;
  final DateTime? deadline;
  final DateTime createdAt;

  Task copyWith({
    String? title,
    String? projectId,
    String? description,
    TaskCategory? category,
    TaskStatus? status,
    String? assigneeId,
    DateTime? deadline,
  }) {
    return Task(
      id: id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      assigneeId: assigneeId ?? this.assigneeId,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt,
    );
  }

  TaskStatus get nextStatus {
    switch (status) {
      case TaskStatus.todo:
        return TaskStatus.inProgress;
      case TaskStatus.inProgress:
        return TaskStatus.done;
      case TaskStatus.done:
        return TaskStatus.todo;
    }
  }

  // toJson() removed
}
