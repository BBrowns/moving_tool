import 'package:flutter/foundation.dart';
import 'package:moving_tool_flutter/core/error/exceptions.dart';
import 'package:moving_tool_flutter/data/services/database_service.dart';
import 'package:moving_tool_flutter/features/expenses/domain/entities/expense.dart';
import 'package:moving_tool_flutter/features/expenses/domain/entities/settlement_batch.dart';
import 'package:moving_tool_flutter/features/expenses/domain/repositories/expenses_repository.dart';

class ExpensesRepositoryImpl implements ExpensesRepository {
  @override
  Future<List<Expense>> getExpenses() async {
    try {
      return DatabaseService.getAllExpenses();
    } catch (e) {
      debugPrint('Error getting expenses: $e');
      throw FetchFailure('Failed to load expenses', e);
    }
  }

  @override
  Future<void> saveExpense(Expense expense) async {
    try {
      await DatabaseService.saveExpense(expense);
    } catch (e) {
      debugPrint('Error saving expense: $e');
      throw SaveFailure('Failed to save expense', e);
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      await DatabaseService.deleteExpense(id);
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      throw DeleteFailure('Failed to delete expense', e);
    }
  }

  @override
  Future<List<SettlementBatch>> getSettlementBatches() async {
    try {
      return DatabaseService.getAllSettlementBatches();
    } catch (e) {
      debugPrint('Error getting settlement batches: $e');
      throw FetchFailure('Failed to load settlement batches', e);
    }
  }

  @override
  Future<void> saveSettlementBatch(SettlementBatch batch) async {
    try {
      await DatabaseService.saveSettlementBatch(batch);
    } catch (e) {
      debugPrint('Error saving settlement batch: $e');
      throw SaveFailure('Failed to save settlement batch', e);
    }
  }

  @override
  Future<void> deleteSettlementBatch(String id) async {
    try {
      await DatabaseService.deleteSettlementBatch(id);
    } catch (e) {
      debugPrint('Error deleting settlement batch: $e');
      throw DeleteFailure('Failed to delete settlement batch', e);
    }
  }
}
