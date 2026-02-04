import 'package:flutter/material.dart';

// Domain Models - Expense & Settlement (simplified, no Hive)
enum ExpenseCategory {
  verhuizing,
  inrichting,
  reparaties,
  nutsvoorzieningen,
  administratie,
  overig,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.verhuizing:
        return 'Verhuizing';
      case ExpenseCategory.inrichting:
        return 'Inrichting';
      case ExpenseCategory.reparaties:
        return 'Reparaties';
      case ExpenseCategory.nutsvoorzieningen:
        return 'Nutsvoorzieningen';
      case ExpenseCategory.administratie:
        return 'Administratie';
      case ExpenseCategory.overig:
        return 'Overig';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.verhuizing:
        return Icons.local_shipping_rounded;
      case ExpenseCategory.inrichting:
        return Icons.chair_rounded;
      case ExpenseCategory.reparaties:
        return Icons.build_rounded;
      case ExpenseCategory.nutsvoorzieningen:
        return Icons.lightbulb_rounded;
      case ExpenseCategory.administratie:
        return Icons.receipt_long_rounded;
      case ExpenseCategory.overig:
        return Icons.push_pin_rounded;
    }
  }
}

class Expense {

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.paidById,
    required this.splitBetweenIds,
    required this.date,
    required this.createdAt, this.receiptUrl,
    this.notes = '',
    this.settlementId,
  });
  final String id;
  final String description;
  final double amount;
  final ExpenseCategory category;
  final String paidById;
  final List<String> splitBetweenIds;
  final DateTime date;
  final String? settlementId;
  final String? receiptUrl;
  final String notes;
  final DateTime createdAt;

  double get amountPerPerson {
    if (splitBetweenIds.isEmpty) return amount;
    return amount / splitBetweenIds.length;
  }

  Expense copyWith({
    String? description,
    double? amount,
    ExpenseCategory? category,
    String? paidById,
    List<String>? splitBetweenIds,
    DateTime? date,
    String? receiptUrl,
    String? notes,
    String? settlementId,
  }) {
    return Expense(
      id: id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paidById: paidById ?? this.paidById,
      splitBetweenIds: splitBetweenIds ?? this.splitBetweenIds,
      date: date ?? this.date,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      settlementId: settlementId ?? this.settlementId,
    );
  }

  // toJson() removed
}

class Settlement {

  Settlement({
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
  });
  final String fromUserId;
  final String toUserId;
  final double amount;

  // fromJson and toJson removed
}

List<Settlement> calculateSettlements(
  List<Expense> expenses,
  List<String> userIds,
) {
  final Map<String, double> balances = {};
  for (final userId in userIds) {
    balances[userId] = 0;
  }

  for (final expense in expenses) {
    if (expense.settlementId != null) continue; // Skip settled expenses

    balances[expense.paidById] =
        (balances[expense.paidById] ?? 0) + expense.amount;
    final perPerson = expense.amountPerPerson;
    for (final userId in expense.splitBetweenIds) {
      balances[userId] = (balances[userId] ?? 0) - perPerson;
    }
  }

  final List<Settlement> settlements = [];
  final debtors = <String, double>{};
  final creditors = <String, double>{};

  balances.forEach((userId, balance) {
    if (balance < -0.01) {
      debtors[userId] = -balance;
    } else if (balance > 0.01) {
      creditors[userId] = balance;
    }
  });

  for (final debtor in debtors.entries) {
    var remaining = debtor.value;
    for (final creditor in creditors.entries) {
      if (remaining <= 0.01) break;
      if (creditor.value <= 0.01) continue;

      final settleAmount =
          remaining < creditor.value ? remaining : creditor.value;
      settlements.add(Settlement(
        fromUserId: debtor.key,
        toUserId: creditor.key,
        amount: settleAmount,
      ));

      remaining -= settleAmount;
      creditors[creditor.key] = creditor.value - settleAmount;
    }
  }

  return settlements;
}

