// Domain Models - Packing (simplified, no Hive)
// Note: Using PackingBox instead of Box to avoid conflict with Hive's Box type
enum BoxStatus {
  empty,
  packing,
  packed,
  moved,
  unpacked,
}

extension BoxStatusExtension on BoxStatus {
  String get label {
    switch (this) {
      case BoxStatus.empty:
        return 'Leeg';
      case BoxStatus.packing:
        return 'Bezig';
      case BoxStatus.packed:
        return 'Ingepakt';
      case BoxStatus.moved:
        return 'Verhuisd';
      case BoxStatus.unpacked:
        return 'Uitgepakt';
    }
  }

  String get icon {
    switch (this) {
      case BoxStatus.empty:
        return '📭';
      case BoxStatus.packing:
        return '📦';
      case BoxStatus.packed:
        return '✅';
      case BoxStatus.moved:
        return '🚚';
      case BoxStatus.unpacked:
        return '🎉';
    }
  }
}

class Room {
  final String id;
  final String name;
  final String icon;
  final String color;
  final double? budget;
  final double squareMeters;
  final String notes;
  final DateTime createdAt;

  Room({
    required this.id,
    required this.name,
    this.icon = '📦',
    this.color = '#6366F1',
    this.budget,
    this.squareMeters = 0,
    this.notes = '',
    required this.createdAt,
  });

  Room copyWith({
    String? name,
    String? icon,
    String? color,
    double? budget,
    double? squareMeters,
    String? notes,
  }) {
    return Room(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      budget: budget ?? this.budget,
      squareMeters: squareMeters ?? this.squareMeters,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}

/// Renamed from Box to PackingBox to avoid conflict with Hive's Box type
class PackingBox {
  final String id;
  final String roomId;
  final String label;
  final BoxStatus status;
  final bool isFragile;
  final String notes;
  final DateTime createdAt;

  PackingBox({
    required this.id,
    required this.roomId,
    required this.label,
    this.status = BoxStatus.empty,
    this.isFragile = false,
    this.notes = '',
    required this.createdAt,
  });

  PackingBox copyWith({
    String? roomId,
    String? label,
    BoxStatus? status,
    bool? isFragile,
    String? notes,
  }) {
    return PackingBox(
      id: id,
      roomId: roomId ?? this.roomId,
      label: label ?? this.label,
      status: status ?? this.status,
      isFragile: isFragile ?? this.isFragile,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}

class BoxItem {
  final String id;
  final String boxId;
  final String name;
  final int quantity;
  final double? estimatedValue;
  final DateTime createdAt;

  BoxItem({
    required this.id,
    required this.boxId,
    required this.name,
    this.quantity = 1,
    this.estimatedValue,
    required this.createdAt,
  });

  BoxItem copyWith({
    String? boxId,
    String? name,
    int? quantity,
    double? estimatedValue,
  }) {
    return BoxItem(
      id: id,
      boxId: boxId ?? this.boxId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      createdAt: createdAt,
    );
  }
}
