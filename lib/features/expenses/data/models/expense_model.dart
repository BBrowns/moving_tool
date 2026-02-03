
import 'package:moving_tool_flutter/features/expenses/domain/entities/expense.dart';

class ExpenseModel extends Expense {
  ExpenseModel({
    required super.id,
    required super.description,
    required super.amount,
    required super.category,
    required super.paidById,
    required super.splitBetweenIds,
    required super.date,
    super.receiptUrl,
    super.notes,
    required super.createdAt,
    super.settlementId,
  });

  factory ExpenseModel.fromEntity(Expense entity) {
    return ExpenseModel(
      id: entity.id,
      description: entity.description,
      amount: entity.amount,
      category: entity.category,
      paidById: entity.paidById,
      splitBetweenIds: entity.splitBetweenIds,
      date: entity.date,
      receiptUrl: entity.receiptUrl,
      notes: entity.notes,
      createdAt: entity.createdAt,
      settlementId: entity.settlementId,
    );
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ExpenseCategory.overig,
      ),
      paidById: json['paidById'] as String,
      splitBetweenIds: List<String>.from(json['splitBetweenIds'] as List),
      date: DateTime.parse(json['date'] as String),
      receiptUrl: json['receiptUrl'] as String?,
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      settlementId: json['settlementId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category.name,
      'paidById': paidById,
      'splitBetweenIds': splitBetweenIds,
      'date': date.toIso8601String(),
      'receiptUrl': receiptUrl,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'settlementId': settlementId,
    };
  }
}
