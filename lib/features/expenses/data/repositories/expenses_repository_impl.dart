import 'package:moving_tool_flutter/data/services/database_service.dart';
import 'package:moving_tool_flutter/features/expenses/domain/entities/expense.dart';
import 'package:moving_tool_flutter/features/expenses/domain/entities/settlement_batch.dart';
import 'package:moving_tool_flutter/features/expenses/domain/repositories/expenses_repository.dart';

class ExpensesRepositoryImpl implements ExpensesRepository {
  @override
  Future<List<Expense>> getExpenses() async {
    return DatabaseService.getAllExpenses();
  }

  @override
  Future<void> saveExpense(Expense expense) async {
    return DatabaseService.saveExpense(expense);
  }

  @override
  Future<void> deleteExpense(String id) async {
    return DatabaseService.deleteExpense(id);
  }

  @override
  Future<List<SettlementBatch>> getSettlementBatches() async {
    return DatabaseService.getAllSettlementBatches();
  }

  @override
  Future<void> saveSettlementBatch(SettlementBatch batch) async {
    return DatabaseService.saveSettlementBatch(batch);
  }

  @override
  Future<void> deleteSettlementBatch(String id) async {
    return DatabaseService.deleteSettlementBatch(id);
  }
}
