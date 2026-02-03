import 'package:flutter/material.dart';

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

  IconData get icon {
    switch (this) {
      case BoxStatus.empty:
        return Icons.check_box_outline_blank_rounded;
      case BoxStatus.packing:
        return Icons.hourglass_empty_rounded;
      case BoxStatus.packed:
        return Icons.check_circle_rounded;
      case BoxStatus.moved:
        return Icons.local_shipping_rounded;
      case BoxStatus.unpacked:
        return Icons.celebration_rounded;
    }
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
