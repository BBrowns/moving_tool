import 'package:moving_tool_flutter/core/models/item_dimensions.dart';

/// Room dimensions for AR scanning and visualization.
class RoomDimensions {
  const RoomDimensions({
    required this.lengthCm,
    required this.widthCm,
    required this.heightCm,
  });

  final double lengthCm;
  final double widthCm;
  final double heightCm;

  /// Floor area in square meters
  double get floorAreaM2 => (lengthCm * widthCm) / 10000;

  /// Volume in cubic meters
  double get volumeM3 => (lengthCm * widthCm * heightCm) / 1e6;

  RoomDimensions copyWith({
    double? lengthCm,
    double? widthCm,
    double? heightCm,
  }) {
    return RoomDimensions(
      lengthCm: lengthCm ?? this.lengthCm,
      widthCm: widthCm ?? this.widthCm,
      heightCm: heightCm ?? this.heightCm,
    );
  }

  Map<String, dynamic> toJson() => {
    'lengthCm': lengthCm,
    'widthCm': widthCm,
    'heightCm': heightCm,
  };

  factory RoomDimensions.fromJson(Map<String, dynamic> json) {
    return RoomDimensions(
      lengthCm: (json['lengthCm'] as num).toDouble(),
      widthCm: (json['widthCm'] as num).toDouble(),
      heightCm: (json['heightCm'] as num).toDouble(),
    );
  }

  @override
  String toString() =>
      '${(lengthCm / 100).toStringAsFixed(1)}×${(widthCm / 100).toStringAsFixed(1)}m';
}

/// 3D position and rotation for AR placement.
class ARPlacement {
  const ARPlacement({this.x = 0, this.y = 0, this.z = 0, this.rotationY = 0});

  final double x;
  final double y;
  final double z;
  final double rotationY; // Degrees

  ARPlacement copyWith({double? x, double? y, double? z, double? rotationY}) {
    return ARPlacement(
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
      rotationY: rotationY ?? this.rotationY,
    );
  }

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'z': z,
    'rotationY': rotationY,
  };

  factory ARPlacement.fromJson(Map<String, dynamic> json) {
    return ARPlacement(
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      z: (json['z'] as num?)?.toDouble() ?? 0,
      rotationY: (json['rotationY'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// A virtual item to be visualized in AR (ghost furniture).
class VirtualItem {
  const VirtualItem({
    required this.id,
    required this.roomId,
    required this.name,
    required this.dimensions,
    this.shoppingItemId,
    this.placement = const ARPlacement(),
    this.color = '#4CAF50', // Default green
  });

  final String id;
  final String roomId;
  final String name;
  final ItemDimensions dimensions;

  /// Link to shopping list item (if applicable)
  final String? shoppingItemId;

  final ARPlacement placement;
  final String color;

  VirtualItem copyWith({
    String? name,
    ItemDimensions? dimensions,
    String? shoppingItemId,
    ARPlacement? placement,
    String? color,
  }) {
    return VirtualItem(
      id: id,
      roomId: roomId,
      name: name ?? this.name,
      dimensions: dimensions ?? this.dimensions,
      shoppingItemId: shoppingItemId ?? this.shoppingItemId,
      placement: placement ?? this.placement,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'roomId': roomId,
    'name': name,
    'dimensions': dimensions.toJson(),
    'shoppingItemId': shoppingItemId,
    'placement': placement.toJson(),
    'color': color,
  };

  factory VirtualItem.fromJson(Map<String, dynamic> json) {
    return VirtualItem(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      name: json['name'] as String,
      dimensions: ItemDimensions.fromJson(
        json['dimensions'] as Map<String, dynamic>,
      ),
      shoppingItemId: json['shoppingItemId'] as String?,
      placement: json['placement'] != null
          ? ARPlacement.fromJson(json['placement'] as Map<String, dynamic>)
          : const ARPlacement(),
      color: json['color'] as String? ?? '#4CAF50',
    );
  }
}

/// A room that has been scanned or created for AR visualization.
class Room {
  const Room({
    required this.id,
    required this.projectId,
    required this.name,
    required this.createdAt,
    this.dimensions,
    this.virtualItems = const [],
    this.thumbnailUrl,
  });

  final String id;
  final String projectId;
  final String name;
  final RoomDimensions? dimensions;
  final List<VirtualItem> virtualItems;
  final String? thumbnailUrl;
  final DateTime createdAt;

  Room copyWith({
    String? name,
    RoomDimensions? dimensions,
    List<VirtualItem>? virtualItems,
    String? thumbnailUrl,
  }) {
    return Room(
      id: id,
      projectId: projectId,
      name: name ?? this.name,
      dimensions: dimensions ?? this.dimensions,
      virtualItems: virtualItems ?? this.virtualItems,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'name': name,
    'dimensions': dimensions?.toJson(),
    'virtualItems': virtualItems.map((v) => v.toJson()).toList(),
    'thumbnailUrl': thumbnailUrl,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      dimensions: json['dimensions'] != null
          ? RoomDimensions.fromJson(json['dimensions'] as Map<String, dynamic>)
          : null,
      virtualItems:
          (json['virtualItems'] as List<dynamic>?)
              ?.map((v) => VirtualItem.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      thumbnailUrl: json['thumbnailUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
