import 'package:moving_tool_flutter/features/expenses/data/models/settlement_model.dart';
import 'package:moving_tool_flutter/features/expenses/domain/entities/settlement_batch.dart';

class SettlementBatchModel extends SettlementBatch {
  SettlementBatchModel({
    required super.id,
    required super.projectId,
    required super.date,
    required super.totalAmount,
    required super.settlements,
    required super.expenseIds,
    required super.createdByUserId,
  });

  factory SettlementBatchModel.fromEntity(SettlementBatch entity) {
    return SettlementBatchModel(
      id: entity.id,
      projectId: entity.projectId,
      date: entity.date,
      totalAmount: entity.totalAmount,
      settlements: entity.settlements
          .map((s) => s is SettlementModel ? s : SettlementModel.fromEntity(s))
          .toList(),
      expenseIds: entity.expenseIds,
      createdByUserId: entity.createdByUserId,
    );
  }

  factory SettlementBatchModel.fromJson(Map<String, dynamic> json) {
    return SettlementBatchModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String? ?? 'p1', // Default for migration
      date: DateTime.parse(json['date'] as String),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      settlements: (json['settlements'] as List<dynamic>)
          .map((e) => SettlementModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      expenseIds: List<String>.from(json['expenseIds'] as List),
      createdByUserId: json['createdByUserId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'date': date.toIso8601String(),
      'totalAmount': totalAmount,
      'settlements': settlements
          .map(
            (e) => (e is SettlementModel
                ? e.toJson()
                : SettlementModel.fromEntity(e).toJson()),
          )
          .toList(),
      'expenseIds': expenseIds,
      'createdByUserId': createdByUserId,
    };
  }
}
