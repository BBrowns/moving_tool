
import 'package:moving_tool_flutter/features/shopping/domain/entities/shopping_item.dart';

class ShoppingItemModel extends ShoppingItem {
  ShoppingItemModel({
    required super.id,
    required super.name,
    super.roomId,
    super.status,
    super.priority,
    super.budgetMin,
    super.budgetMax,
    super.actualPrice,
    super.assigneeId,
    super.notes,
    super.marketplace,
    super.marktplaatsQuery,
    super.isMarktplaatsTracked,
    super.targetPrice,
    required super.createdAt,
  });

  /// Factory to create a Model from a Domain Entity
  factory ShoppingItemModel.fromEntity(ShoppingItem entity) {
    return ShoppingItemModel(
      id: entity.id,
      name: entity.name,
      roomId: entity.roomId,
      status: entity.status,
      priority: entity.priority,
      budgetMin: entity.budgetMin,
      budgetMax: entity.budgetMax,
      actualPrice: entity.actualPrice,
      assigneeId: entity.assigneeId,
      notes: entity.notes,
      marketplace: entity.marketplace,
      marktplaatsQuery: entity.marktplaatsQuery,
      isMarktplaatsTracked: entity.isMarktplaatsTracked,
      targetPrice: entity.targetPrice,
      createdAt: entity.createdAt,
    );
  }

  /// JSON Serialization (Moved from Entity)
  factory ShoppingItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      roomId: json['roomId'] as String?,
      status: ShoppingStatus.values[json['status'] as int],
      priority: ShoppingPriority.values[json['priority'] as int? ?? 1], // Default to medium (1)
      budgetMin: (json['budgetMin'] as num?)?.toDouble(),
      budgetMax: (json['budgetMax'] as num?)?.toDouble(),
      actualPrice: (json['actualPrice'] as num?)?.toDouble(),
      assigneeId: json['assigneeId'] as String?,
      notes: json['notes'] as String? ?? '',
      marketplace: json['marketplace'] != null
          ? MarketplaceDataModel.fromJson(Map<String, dynamic>.from(json['marketplace'] as Map))
          : null,
      marktplaatsQuery: json['marktplaatsQuery'] as String?,
      isMarktplaatsTracked: json['isMarktplaatsTracked'] as bool? ?? false,
      targetPrice: (json['targetPrice'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'roomId': roomId,
      'status': status.index,
      'priority': priority.index,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'actualPrice': actualPrice,
      'assigneeId': assigneeId,
      'notes': notes,
      'marketplace': marketplace != null 
          ? MarketplaceDataModel.fromEntity(marketplace!).toJson() 
          : null,
      'marktplaatsQuery': marktplaatsQuery,
      'isMarktplaatsTracked': isMarktplaatsTracked,
      'targetPrice': targetPrice,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class MarketplaceDataModel extends MarketplaceData {
  MarketplaceDataModel({
    super.url,
    super.askingPrice,
    super.sellerName,
    super.notes,
    super.savedAt,
  });

  factory MarketplaceDataModel.fromEntity(MarketplaceData entity) {
    return MarketplaceDataModel(
      url: entity.url,
      askingPrice: entity.askingPrice,
      sellerName: entity.sellerName,
      notes: entity.notes,
      savedAt: entity.savedAt,
    );
  }

  factory MarketplaceDataModel.fromJson(Map<String, dynamic> json) {
    return MarketplaceDataModel(
      url: json['url'] as String?,
      askingPrice: (json['askingPrice'] as num?)?.toDouble(),
      sellerName: json['sellerName'] as String?,
      notes: json['notes'] as String?,
      savedAt: json['savedAt'] != null ? DateTime.parse(json['savedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'askingPrice': askingPrice,
      'sellerName': sellerName,
      'notes': notes,
      'savedAt': savedAt?.toIso8601String(),
    };
  }
}
