import 'package:moving_tool_flutter/features/expenses/domain/entities/expense.dart';
import 'package:moving_tool_flutter/features/expenses/domain/entities/settlement_batch.dart';

abstract class ExpensesRepository {
  Future<List<Expense>> getExpenses();
  Future<void> saveExpense(Expense expense);
  Future<void> deleteExpense(String id);
  
  // Settlement History
  Future<List<SettlementBatch>> getSettlementBatches();
  Future<void> saveSettlementBatch(SettlementBatch batch);
  Future<void> deleteSettlementBatch(String id);
}
