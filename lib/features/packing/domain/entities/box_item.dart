class BoxItem {
  final String id;
  final String boxId;
  final String name;
  final int quantity;
  final double? estimatedValue;
  final bool isPacked;
  final DateTime createdAt;

  BoxItem({
    required this.id,
    required this.boxId,
    required this.name,
    this.quantity = 1,
    this.estimatedValue,
    this.isPacked = false,
    required this.createdAt,
  });

  BoxItem copyWith({
    String? boxId,
    String? name,
    int? quantity,
    double? estimatedValue,
    bool? isPacked,
  }) {
    return BoxItem(
      id: id,
      boxId: boxId ?? this.boxId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      isPacked: isPacked ?? this.isPacked,
      createdAt: createdAt,
    );
  }
}
