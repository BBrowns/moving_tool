import 'package:moving_tool_flutter/features/expenses/domain/entities/expense.dart';

class SettlementBatch {
  SettlementBatch({
    required this.id,
    required this.projectId,
    required this.date,
    required this.totalAmount,
    required this.settlements,
    required this.expenseIds,
    required this.createdByUserId,
  });
  final String id;
  final String projectId;
  final DateTime date;
  final double totalAmount;
  final List<Settlement> settlements;
  final List<String> expenseIds;
  final String createdByUserId;

  // fromJson and toJson removed
}
