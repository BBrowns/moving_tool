
import 'package:moving_tool_flutter/features/expenses/domain/entities/expense.dart';

class SettlementBatch {
  final String id;
  final DateTime date;
  final double totalAmount;
  final List<Settlement> settlements;
  final List<String> expenseIds;
  final String createdByUserId;

  SettlementBatch({
    required this.id,
    required this.date,
    required this.totalAmount,
    required this.settlements,
    required this.expenseIds,
    required this.createdByUserId,
  });

  factory SettlementBatch.fromJson(Map<String, dynamic> json) {
    return SettlementBatch(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      settlements: (json['settlements'] as List<dynamic>)
          .map((e) => Settlement.fromJson(e as Map<String, dynamic>))
          .toList(),
      expenseIds: List<String>.from(json['expenseIds'] as List),
      createdByUserId: json['createdByUserId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'totalAmount': totalAmount,
      'settlements': settlements.map((e) => e.toJson()).toList(),
      'expenseIds': expenseIds,
      'createdByUserId': createdByUserId,
    };
  }
}
