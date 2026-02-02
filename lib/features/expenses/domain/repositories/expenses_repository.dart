import 'package:moving_tool_flutter/features/expenses/domain/entities/expense.dart';

abstract class ExpensesRepository {
  Future<List<Expense>> getExpenses();
  Future<void> saveExpense(Expense expense);
  Future<void> deleteExpense(String id);
}
