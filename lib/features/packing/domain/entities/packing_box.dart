enum BoxStatus { empty, packing, packed, moved, unpacked }

/// Renamed from Box to PackingBox to avoid conflict with Hive's Box type
class PackingBox {

  const PackingBox({
    required this.id,
    required this.roomId,
    required this.label,
    required this.createdAt, this.status = BoxStatus.empty,
    this.isFragile = false,
    this.notes = '',
  });
  final String id;
  final String roomId;
  final String label;
  final BoxStatus status;
  final bool isFragile;
  final String notes;
  final DateTime createdAt;

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
