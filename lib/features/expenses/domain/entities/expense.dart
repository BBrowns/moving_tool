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
        return '🚚 Verhuizing';
      case ExpenseCategory.inrichting:
        return '🛋️ Inrichting';
      case ExpenseCategory.reparaties:
        return '🔧 Reparaties';
      case ExpenseCategory.nutsvoorzieningen:
        return '💡 Nutsvoorzieningen';
      case ExpenseCategory.administratie:
        return '📋 Administratie';
      case ExpenseCategory.overig:
        return '📌 Overig';
    }
  }

  String get icon {
    switch (this) {
      case ExpenseCategory.verhuizing:
        return '🚚';
      case ExpenseCategory.inrichting:
        return '🛋️';
      case ExpenseCategory.reparaties:
        return '🔧';
      case ExpenseCategory.nutsvoorzieningen:
        return '💡';
      case ExpenseCategory.administratie:
        return '📋';
      case ExpenseCategory.overig:
        return '📌';
    }
  }
}

class Expense {
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

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.paidById,
    required this.splitBetweenIds,
    required this.date,
    this.receiptUrl,
    this.notes = '',
    required this.createdAt,
    this.settlementId,
  });

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

class Settlement {
  final String fromUserId;
  final String toUserId;
  final double amount;

  Settlement({
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
  });

  factory Settlement.fromJson(Map<String, dynamic> json) {
    return Settlement(
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

