import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:moving_tool_flutter/features/expenses/domain/entities/expense.dart';
import 'package:moving_tool_flutter/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:moving_tool_flutter/features/expenses/data/repositories/expenses_repository_impl.dart';

const _uuid = Uuid();

// ============================================================================
// Repository Provider
// ============================================================================

final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  return ExpensesRepositoryImpl();
});

// ============================================================================
// Expense Notifier
// ============================================================================

class ExpenseNotifier extends Notifier<List<Expense>> {
  late final ExpensesRepository repository;

  @override
  List<Expense> build() {
    repository = ref.watch(expensesRepositoryProvider);
    return [];
  }

  Future<void> load() async {
    state = await repository.getExpenses();
  }

  Future<void> add({
    required String description,
    required double amount,
    required ExpenseCategory category,
    required String paidById,
    required List<String> splitBetweenIds,
    DateTime? date,
  }) async {
    final expense = Expense(
      id: _uuid.v4(),
      description: description,
      amount: amount,
      category: category,
      paidById: paidById,
      splitBetweenIds: splitBetweenIds,
      date: date ?? DateTime.now(),
      createdAt: DateTime.now(),
    );
    await repository.saveExpense(expense);
    state = [...state, expense];
  }

  Future<void> update(Expense expense) async {
    await repository.saveExpense(expense);
    state = state.map((e) => e.id == expense.id ? expense : e).toList();
  }

  Future<void> delete(String id) async {
    await repository.deleteExpense(id);
    state = state.where((e) => e.id != id).toList();
  }

  double get totalExpenses => state.fold(0.0, (sum, e) => sum + e.amount);
}

final expenseProvider = NotifierProvider<ExpenseNotifier, List<Expense>>(ExpenseNotifier.new);
