
import 'package:moving_tool_flutter/features/packing/domain/entities/room.dart';

class RoomModel extends Room {
  const RoomModel({
    required super.id,
    required super.name,
    required super.createdAt, super.icon,
    super.color,
    super.budget,
    super.squareMeters,
    super.notes,
  });

  factory RoomModel.fromEntity(Room entity) {
    return RoomModel(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      color: entity.color,
      budget: entity.budget,
      squareMeters: entity.squareMeters,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? '📦',
      color: json['color'] as String? ?? '#6366F1',
      budget: (json['budget'] as num?)?.toDouble(),
      squareMeters: (json['squareMeters'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'budget': budget,
      'squareMeters': squareMeters,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
