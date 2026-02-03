
import 'package:moving_tool_flutter/features/packing/domain/entities/box_item.dart';

class BoxItemModel extends BoxItem {
  const BoxItemModel({
    required super.id,
    required super.boxId,
    required super.name,
    super.quantity,
    super.estimatedValue,
    super.isPacked,
    required super.createdAt,
  });

  factory BoxItemModel.fromEntity(BoxItem entity) {
    return BoxItemModel(
      id: entity.id,
      boxId: entity.boxId,
      name: entity.name,
      quantity: entity.quantity,
      estimatedValue: entity.estimatedValue,
      isPacked: entity.isPacked,
      createdAt: entity.createdAt,
    );
  }

  factory BoxItemModel.fromJson(Map<String, dynamic> json) {
    return BoxItemModel(
      id: json['id'] as String,
      boxId: json['boxId'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int? ?? 1,
      estimatedValue: (json['estimatedValue'] as num?)?.toDouble(),
      isPacked: json['isPacked'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'boxId': boxId,
      'name': name,
      'quantity': quantity,
      'estimatedValue': estimatedValue,
      'isPacked': isPacked,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
