
import 'package:moving_tool_flutter/features/tasks/domain/entities/task.dart';

class TaskModel extends Task {
  TaskModel({
    required super.id,
    required super.title,
    super.description,
    required super.category,
    super.status,
    super.assigneeId,
    super.deadline,
    required super.createdAt,
  });

  factory TaskModel.fromEntity(Task entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      category: entity.category,
      status: entity.status,
      assigneeId: entity.assigneeId,
      deadline: entity.deadline,
      createdAt: entity.createdAt,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: TaskCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TaskCategory.overig,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.todo,
      ),
      assigneeId: json['assigneeId'] as String?,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
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
