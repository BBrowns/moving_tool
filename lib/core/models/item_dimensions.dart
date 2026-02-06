/// Physical dimensions for items, furniture, and transport calculations.
class ItemDimensions {
  const ItemDimensions({
    this.heightCm,
    this.widthCm,
    this.depthCm,
    this.weightKg,
  });

  final double? heightCm;
  final double? widthCm;
  final double? depthCm;
  final double? weightKg;

  /// Volume in cubic meters (m³)
  double get volumeM3 {
    if (heightCm == null || widthCm == null || depthCm == null) return 0;
    return (heightCm! * widthCm! * depthCm!) / 1e6;
  }

  /// Volume in liters
  double get volumeLiters => volumeM3 * 1000;

  /// Check if dimensions are complete
  bool get isComplete => heightCm != null && widthCm != null && depthCm != null;

  ItemDimensions copyWith({
    double? heightCm,
    double? widthCm,
    double? depthCm,
    double? weightKg,
  }) {
    return ItemDimensions(
      heightCm: heightCm ?? this.heightCm,
      widthCm: widthCm ?? this.widthCm,
      depthCm: depthCm ?? this.depthCm,
      weightKg: weightKg ?? this.weightKg,
    );
  }

  Map<String, dynamic> toJson() => {
    'heightCm': heightCm,
    'widthCm': widthCm,
    'depthCm': depthCm,
    'weightKg': weightKg,
  };

  factory ItemDimensions.fromJson(Map<String, dynamic> json) {
    return ItemDimensions(
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      widthCm: (json['widthCm'] as num?)?.toDouble(),
      depthCm: (json['depthCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
    );
  }

  @override
  String toString() =>
      '${heightCm?.toStringAsFixed(0) ?? "?"}×${widthCm?.toStringAsFixed(0) ?? "?"}×${depthCm?.toStringAsFixed(0) ?? "?"} cm';
}
