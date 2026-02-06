import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:moving_tool_flutter/data/services/database_service.dart';
import 'package:moving_tool_flutter/features/expenses/domain/entities/expense.dart';
import 'package:moving_tool_flutter/features/expenses/domain/entities/settlement_batch.dart';

part 'expenses_local_data_source.g.dart';

/// Interface for local data operations related to expenses
abstract interface class ExpensesLocalDataSource {
  Future<List<Expense>> getAllExpenses();
  Future<void> saveExpense(Expense expense);
  Future<void> deleteExpense(String id);
  Future<List<SettlementBatch>> getAllSettlementBatches();
  Future<void> saveSettlementBatch(SettlementBatch batch);
  Future<void> deleteSettlementBatch(String id);
}

/// Implementation using the static DatabaseService
/// This wrapper allows us to mock the data source in tests
class ExpensesLocalDataSourceImpl implements ExpensesLocalDataSource {
  const ExpensesLocalDataSourceImpl();

  @override
  Future<List<Expense>> getAllExpenses() async {
    return DatabaseService.getAllExpenses();
  }

  @override
  Future<void> saveExpense(Expense expense) {
    return DatabaseService.saveExpense(expense);
  }

  @override
  Future<void> deleteExpense(String id) {
    return DatabaseService.deleteExpense(id);
  }

  @override
  Future<List<SettlementBatch>> getAllSettlementBatches() async {
    return DatabaseService.getAllSettlementBatches();
  }

  @override
  Future<void> saveSettlementBatch(SettlementBatch batch) {
    return DatabaseService.saveSettlementBatch(batch);
  }

  @override
  Future<void> deleteSettlementBatch(String id) {
    return DatabaseService.deleteSettlementBatch(id);
  }
}

@Riverpod(keepAlive: true)
ExpensesLocalDataSource expensesLocalDataSource(Ref ref) {
  return const ExpensesLocalDataSourceImpl();
}
