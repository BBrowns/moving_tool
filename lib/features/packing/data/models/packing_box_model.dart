
import 'package:moving_tool_flutter/features/packing/domain/entities/packing_box.dart';

class PackingBoxModel extends PackingBox {
  const PackingBoxModel({
    required super.id,
    required super.roomId,
    required super.label,
    required super.createdAt, super.notes,
    super.status,
    super.isFragile,
  });

  factory PackingBoxModel.fromEntity(PackingBox entity) {
    return PackingBoxModel(
      id: entity.id,
      roomId: entity.roomId,
      label: entity.label,
      notes: entity.notes,
      status: entity.status,
      isFragile: entity.isFragile,
      createdAt: entity.createdAt,
    );
  }

  factory PackingBoxModel.fromJson(Map<String, dynamic> json) {
    return PackingBoxModel(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      label: json['label'] as String,
      notes: json['notes'] as String? ?? '',
      status: BoxStatus.values[json['status'] as int],
      isFragile: json['isFragile'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'label': label,
      'notes': notes,
      'status': status.index,
      'isFragile': isFragile,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
