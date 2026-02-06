/// Ownership share for an asset between project members.
class OwnershipShare {
  const OwnershipShare({
    required this.userId,
    required this.percentage,
    this.userName,
    this.amountPaid,
    this.isPaidInFull = false,
  });

  final String userId;
  final String? userName;

  /// Value between 0.0 and 1.0 (e.g., 0.5 = 50%)
  final double percentage;

  /// Amount this owner has actually paid
  final double? amountPaid;

  /// Whether this owner has settled their share
  final bool isPaidInFull;

  OwnershipShare copyWith({
    String? userId,
    String? userName,
    double? percentage,
    double? amountPaid,
    bool? isPaidInFull,
  }) {
    return OwnershipShare(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      percentage: percentage ?? this.percentage,
      amountPaid: amountPaid ?? this.amountPaid,
      isPaidInFull: isPaidInFull ?? this.isPaidInFull,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'percentage': percentage,
    'amountPaid': amountPaid,
    'isPaidInFull': isPaidInFull,
  };

  factory OwnershipShare.fromJson(Map<String, dynamic> json) {
    return OwnershipShare(
      userId: json['userId'] as String,
      userName: json['userName'] as String?,
      percentage: (json['percentage'] as num).toDouble(),
      amountPaid: (json['amountPaid'] as num?)?.toDouble(),
      isPaidInFull: json['isPaidInFull'] as bool? ?? false,
    );
  }
}
