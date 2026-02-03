import 'package:flutter/material.dart';

enum ShoppingStatus {
  needed,
  searching,
  found,
  purchased,
}

extension ShoppingStatusExtension on ShoppingStatus {
  String get label {
    switch (this) {
      case ShoppingStatus.needed:
        return 'Nodig';
      case ShoppingStatus.searching:
        return 'Zoeken';
      case ShoppingStatus.found:
        return 'Gevonden';
      case ShoppingStatus.purchased:
        return 'Gekocht';
    }
  }

  IconData get icon {
    switch (this) {
      case ShoppingStatus.needed:
        return Icons.format_list_bulleted_rounded;
      case ShoppingStatus.searching:
        return Icons.search_rounded;
      case ShoppingStatus.found:
        return Icons.bookmark_rounded;
      case ShoppingStatus.purchased:
        return Icons.check_circle_rounded;
    }
  }
}

enum ShoppingPriority {
  low,
  medium,
  high,
}

extension ShoppingPriorityExtension on ShoppingPriority {
  String get label {
    switch (this) {
      case ShoppingPriority.low:
        return 'Laag';
      case ShoppingPriority.medium:
        return 'Gemiddeld';
      case ShoppingPriority.high:
        return 'Hoog';
    }
  }
}

class MarketplaceData {
  final String? url;
  final double? askingPrice;
  final String? sellerName;
  final String? notes;
  final DateTime? savedAt;

  MarketplaceData({
    this.url,
    this.askingPrice,
    this.sellerName,
    this.notes,
    this.savedAt,
  });

  MarketplaceData copyWith({
    String? url,
    double? askingPrice,
    String? sellerName,
    String? notes,
    DateTime? savedAt,
  }) {
    return MarketplaceData(
      url: url ?? this.url,
      askingPrice: askingPrice ?? this.askingPrice,
      sellerName: sellerName ?? this.sellerName,
      notes: notes ?? this.notes,
      savedAt: savedAt ?? this.savedAt,
    );
  }


}

class ShoppingItem {
  final String id;
  final String name;
  final String? roomId;
  final ShoppingStatus status;
  final ShoppingPriority priority;
  final double? budgetMin;
  final double? budgetMax;
  final double? actualPrice;
  final String? assigneeId;
  final String notes;
  final MarketplaceData? marketplace;
  final String? marktplaatsQuery;
  final bool isMarktplaatsTracked;
  final double? targetPrice;
  final DateTime createdAt;

  ShoppingItem({
    required this.id,
    required this.name,
    this.roomId,
    this.status = ShoppingStatus.needed,
    this.priority = ShoppingPriority.medium,
    this.budgetMin,
    this.budgetMax,
    this.actualPrice,
    this.assigneeId,
    this.notes = '',
    this.marketplace,
    this.marktplaatsQuery,
    this.isMarktplaatsTracked = false,
    this.targetPrice,
    required this.createdAt,
  });

  ShoppingItem copyWith({
    String? name,
    String? roomId,
    ShoppingStatus? status,
    ShoppingPriority? priority,
    double? budgetMin,
    double? budgetMax,
    double? actualPrice,
    String? assigneeId,
    String? notes,
    MarketplaceData? marketplace,
    String? marktplaatsQuery,
    bool? isMarktplaatsTracked,
    double? targetPrice,
  }) {
    return ShoppingItem(
      id: id,
      name: name ?? this.name,
      roomId: roomId ?? this.roomId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      actualPrice: actualPrice ?? this.actualPrice,
      assigneeId: assigneeId ?? this.assigneeId,
      notes: notes ?? this.notes,
      marketplace: marketplace ?? this.marketplace,
      marktplaatsQuery: marktplaatsQuery ?? this.marktplaatsQuery,
      isMarktplaatsTracked: isMarktplaatsTracked ?? this.isMarktplaatsTracked,
      targetPrice: targetPrice ?? this.targetPrice,
      createdAt: createdAt,
    );
  }


}
