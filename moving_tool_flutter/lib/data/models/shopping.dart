// Domain Models - Shopping (simplified, no Hive)
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

  String get icon {
    switch (this) {
      case ShoppingStatus.needed:
        return '📝';
      case ShoppingStatus.searching:
        return '🔍';
      case ShoppingStatus.found:
        return '✨';
      case ShoppingStatus.purchased:
        return '✅';
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
      createdAt: createdAt,
    );
  }
}
