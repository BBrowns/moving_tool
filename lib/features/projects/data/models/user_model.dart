
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.name,
    required super.color,
  });

  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      color: entity.color,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }
}
