import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';

class ProjectMemberModel extends ProjectMember {
  const ProjectMemberModel({
    required super.id,
    required super.name,
    required super.role,
    super.photoUrl,
    super.color,
  });

  factory ProjectMemberModel.fromEntity(ProjectMember entity) {
    return ProjectMemberModel(
      id: entity.id,
      name: entity.name,
      role: entity.role,
      photoUrl: entity.photoUrl,
      color: entity.color,
    );
  }

  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) {
    return ProjectMemberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: ProjectRole.values.firstWhere(
        (e) => e.name == (json['role'] as String?),
        orElse: () => ProjectRole.viewer, // Default fallback
      ),
      photoUrl: json['photoUrl'] as String?,
      color: json['color'] as String? ?? '#6366F1', // Default if missing
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role.name,
      'photoUrl': photoUrl,
      'color': color,
    };
  }
}
