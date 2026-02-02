// Domain Models - Task (simplified, no Hive annotations)
enum TaskCategory {
  administratie,
  klussen,
  inkopen,
  schoonmaken,
  verhuizing,
  overig,
}

enum TaskStatus {
  todo,
  inProgress,
  done,
}

extension TaskCategoryExtension on TaskCategory {
  String get label {
    switch (this) {
      case TaskCategory.administratie:
        return '📋 Administratie';
      case TaskCategory.klussen:
        return '🔧 Klussen';
      case TaskCategory.inkopen:
        return '🛒 Inkopen';
      case TaskCategory.schoonmaken:
        return '🧹 Schoonmaken';
      case TaskCategory.verhuizing:
        return '📦 Verhuizing';
      case TaskCategory.overig:
        return '📌 Overig';
    }
  }

  String get icon {
    switch (this) {
      case TaskCategory.administratie:
        return '📋';
      case TaskCategory.klussen:
        return '🔧';
      case TaskCategory.inkopen:
        return '🛒';
      case TaskCategory.schoonmaken:
        return '🧹';
      case TaskCategory.verhuizing:
        return '📦';
      case TaskCategory.overig:
        return '📌';
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
  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final TaskStatus status;
  final String? assigneeId;
  final DateTime? deadline;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    this.status = TaskStatus.todo,
    this.assigneeId,
    this.deadline,
    required this.createdAt,
  });

  Task copyWith({
    String? title,
    String? description,
    TaskCategory? category,
    TaskStatus? status,
    String? assigneeId,
    DateTime? deadline,
  }) {
    return Task(
      id: id,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'status': status.name,
      'assigneeId': assigneeId,
      'deadline': deadline?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
