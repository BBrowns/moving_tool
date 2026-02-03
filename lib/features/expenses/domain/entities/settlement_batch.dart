
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

  // fromJson and toJson removed
}
