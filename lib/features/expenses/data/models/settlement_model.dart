
import 'package:moving_tool_flutter/features/expenses/domain/entities/expense.dart';

class SettlementModel extends Settlement {
  SettlementModel({
    required super.fromUserId,
    required super.toUserId,
    required super.amount,
  });

  factory SettlementModel.fromEntity(Settlement entity) {
    return SettlementModel(
      fromUserId: entity.fromUserId,
      toUserId: entity.toUserId,
      amount: entity.amount,
    );
  }

  factory SettlementModel.fromJson(Map<String, dynamic> json) {
    return SettlementModel(
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'amount': amount,
    };
  }
}
