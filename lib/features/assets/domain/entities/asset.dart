import 'package:moving_tool_flutter/core/models/item_dimensions.dart';
import 'package:moving_tool_flutter/features/assets/domain/entities/ownership_share.dart';

/// Status of an owned or tracked asset.
enum AssetStatus {
  wishlist, // On shopping list, not yet purchased
  owned, // Purchased and owned
  disposed, // Sold, given away, or thrown out
  returned, // Returned to store
}

extension AssetStatusExtension on AssetStatus {
  String get label {
    switch (this) {
      case AssetStatus.wishlist:
        return 'Verlanglijst';
      case AssetStatus.owned:
        return 'In bezit';
      case AssetStatus.disposed:
        return 'Weg';
      case AssetStatus.returned:
        return 'Geretourneerd';
    }
  }
}

/// Category of asset for organization and filtering.
enum AssetCategory {
  furniture,
  electronics,
  appliances,
  decor,
  storage,
  outdoor,
  lighting,
  textiles,
  kitchenware,
  bathroom,
  tools,
  other,
}

extension AssetCategoryExtension on AssetCategory {
  String get label {
    switch (this) {
      case AssetCategory.furniture:
        return 'Meubels';
      case AssetCategory.electronics:
        return 'Elektronica';
      case AssetCategory.appliances:
        return 'Apparaten';
      case AssetCategory.decor:
        return 'Decoratie';
      case AssetCategory.storage:
        return 'Opslag';
      case AssetCategory.outdoor:
        return 'Buiten';
      case AssetCategory.lighting:
        return 'Verlichting';
      case AssetCategory.textiles:
        return 'Textiel';
      case AssetCategory.kitchenware:
        return 'Keuken';
      case AssetCategory.bathroom:
        return 'Badkamer';
      case AssetCategory.tools:
        return 'Gereedschap';
      case AssetCategory.other:
        return 'Overig';
    }
  }
}

/// An Asset represents a physical item with ownership tracking.
/// It bridges ShoppingItem (what you want) and Expense (what you paid).
class Asset {
  const Asset({
    required this.id,
    required this.projectId,
    required this.name,
    required this.purchaseDate,
    required this.createdAt,
    this.category,
    this.purchasePrice,
    this.currentValue,
    this.roomId,
    this.warrantyExpiry,
    this.receiptPath,
    this.photoPath,
    this.dimensions,
    this.notes,
    this.ownershipShares,
    this.linkedShoppingItemId,
    this.serialNumber,
    this.brand,
    this.model,
    this.status = AssetStatus.owned,
    this.expenseId,
  });

  final String id;
  final String projectId;
  final String name;
  final AssetCategory? category;
  final DateTime purchaseDate;
  final double? purchasePrice;
  final double? currentValue;
  final String? roomId;
  final DateTime? warrantyExpiry;
  final String? receiptPath;
  final String? photoPath;
  final ItemDimensions? dimensions;
  final String? notes;

  /// Ownership distribution between project members
  final List<OwnershipShare>? ownershipShares;

  /// Link to the original ShoppingItem (if originated from shopping list)
  final String? linkedShoppingItemId;

  final String? serialNumber;
  final String? brand;
  final String? model;
  final AssetStatus status;

  /// Link to the Expense (payment record)
  final String? expenseId;

  final DateTime createdAt;

  /// Check if warranty is still valid
  bool get hasValidWarranty {
    if (warrantyExpiry == null) return false;
    return warrantyExpiry!.isAfter(DateTime.now());
  }

  /// Days until warranty expires (negative if expired)
  int? get daysUntilWarrantyExpiry {
    if (warrantyExpiry == null) return null;
    return warrantyExpiry!.difference(DateTime.now()).inDays;
  }

  /// Calculate total volume if dimensions are set
  double? get volumeM3 => dimensions?.volumeM3;

  /// Calculate what a specific member owes or is owed for this asset.
  double getBalanceForMember(String memberId, String paidByMemberId) {
    final paidShare = paidByMemberId == memberId ? 1.0 : 0.0;
    final ownedShare =
        ownershipShares
            ?.where((o) => o.userId == memberId)
            .fold(0.0, (sum, o) => sum + o.percentage) ??
        0.0;

    if (purchasePrice == null) return 0;
    return purchasePrice! * (paidShare - ownedShare);
  }

  Asset copyWith({
    String? name,
    AssetCategory? category,
    DateTime? purchaseDate,
    double? purchasePrice,
    double? currentValue,
    String? roomId,
    DateTime? warrantyExpiry,
    String? receiptPath,
    String? photoPath,
    ItemDimensions? dimensions,
    String? notes,
    List<OwnershipShare>? ownershipShares,
    String? linkedShoppingItemId,
    String? serialNumber,
    String? brand,
    String? model,
    AssetStatus? status,
    String? expenseId,
  }) {
    return Asset(
      id: id,
      projectId: projectId,
      name: name ?? this.name,
      category: category ?? this.category,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      currentValue: currentValue ?? this.currentValue,
      roomId: roomId ?? this.roomId,
      warrantyExpiry: warrantyExpiry ?? this.warrantyExpiry,
      receiptPath: receiptPath ?? this.receiptPath,
      photoPath: photoPath ?? this.photoPath,
      dimensions: dimensions ?? this.dimensions,
      notes: notes ?? this.notes,
      ownershipShares: ownershipShares ?? this.ownershipShares,
      linkedShoppingItemId: linkedShoppingItemId ?? this.linkedShoppingItemId,
      serialNumber: serialNumber ?? this.serialNumber,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      status: status ?? this.status,
      expenseId: expenseId ?? this.expenseId,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'name': name,
    'category': category?.name,
    'purchaseDate': purchaseDate.toIso8601String(),
    'purchasePrice': purchasePrice,
    'currentValue': currentValue,
    'roomId': roomId,
    'warrantyExpiry': warrantyExpiry?.toIso8601String(),
    'receiptPath': receiptPath,
    'photoPath': photoPath,
    'dimensions': dimensions?.toJson(),
    'notes': notes,
    'ownershipShares': ownershipShares?.map((o) => o.toJson()).toList(),
    'linkedShoppingItemId': linkedShoppingItemId,
    'serialNumber': serialNumber,
    'brand': brand,
    'model': model,
    'status': status.index,
    'expenseId': expenseId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      category: json['category'] != null
          ? AssetCategory.values.firstWhere(
              (c) => c.name == json['category'],
              orElse: () => AssetCategory.other,
            )
          : null,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
      currentValue: (json['currentValue'] as num?)?.toDouble(),
      roomId: json['roomId'] as String?,
      warrantyExpiry: json['warrantyExpiry'] != null
          ? DateTime.parse(json['warrantyExpiry'] as String)
          : null,
      receiptPath: json['receiptPath'] as String?,
      photoPath: json['photoPath'] as String?,
      dimensions: json['dimensions'] != null
          ? ItemDimensions.fromJson(json['dimensions'] as Map<String, dynamic>)
          : null,
      notes: json['notes'] as String?,
      ownershipShares: (json['ownershipShares'] as List<dynamic>?)
          ?.map((o) => OwnershipShare.fromJson(o as Map<String, dynamic>))
          .toList(),
      linkedShoppingItemId: json['linkedShoppingItemId'] as String?,
      serialNumber: json['serialNumber'] as String?,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      status: AssetStatus.values[json['status'] as int? ?? 1],
      expenseId: json['expenseId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
