import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moving_tool_flutter/features/projects/presentation/providers/project_providers.dart';
import 'package:moving_tool_flutter/features/expenses/data/repositories/expenses_repository_impl.dart';
import 'package:moving_tool_flutter/features/expenses/domain/entities/expense.dart';
import 'package:moving_tool_flutter/features/expenses/domain/entities/settlement_batch.dart';
import 'package:moving_tool_flutter/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:moving_tool_flutter/features/playbook/application/playbook_service.dart';
import 'package:moving_tool_flutter/features/playbook/domain/entities/playbook_rule.dart';
import 'package:uuid/uuid.dart';

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
    final project = ref.read(projectProvider);
    if (project == null) return;
    state = await repository.getExpenses(project.id);
  }

  Future<void> add({
    required String description,
    required double amount,
    required ExpenseCategory category,
    required String paidById,
    required List<String> splitBetweenIds,
    DateTime? date,
    String notes = '',
  }) async {
    final project = ref.read(projectProvider);
    if (project == null) return;

    final expense = Expense(
      id: _uuid.v4(),
      projectId: project.id,
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

    // Trigger Playbook Event
    // We don't await this to keep UI snappy, unless critical
    ref
        .read(playbookServiceProvider)
        .handleEvent(
          trigger: EventTrigger.expenseAdded,
          project: project,
          context: {
            'expenseId': expense.id,
            'amount': expense.amount,
            'category': expense.category.name,
          },
        );
  }

  Future<void> update(Expense expense) async {
    await repository.saveExpense(expense);
    state = state.map((e) => e.id == expense.id ? expense : e).toList();
  }

  Future<void> delete(String id) async {
    await repository.deleteExpense(id);
    state = state.where((e) => e.id != id).toList();
  }

  double get totalExpenses => state
      .where((e) => e.settlementId == null)
      .fold(0.0, (sum, e) => sum + e.amount);

  Future<void> settleUp(
    List<String> userIds, {
    required String createdByUserId,
  }) async {
    final openExpenses = state.where((e) => e.settlementId == null).toList();
    if (openExpenses.isEmpty) return;

    final batchId = _uuid.v4();

    // Calculate final settlements for this batch
    final settlements = calculateSettlements(openExpenses, userIds);

    // Create the batch
    final project = ref.read(projectProvider);
    if (project == null) return;

    final batch = SettlementBatch(
      id: batchId,
      projectId: project.id,
      date: DateTime.now(),
      totalAmount: openExpenses.fold(0.0, (sum, e) => sum + e.amount),
      settlements: settlements,
      expenseIds: openExpenses.map((e) => e.id).toList(),
      createdByUserId: createdByUserId,
    );

    // Save the batch
    await repository.saveSettlementBatch(batch);

    // Update all open expenses to be settled
    for (final expense in openExpenses) {
      final updated = expense.copyWith(settlementId: batchId);
      await repository.saveExpense(updated);
    }

    // Refresh state
    state = await repository.getExpenses(project.id);
  }
}

final expenseProvider = NotifierProvider<ExpenseNotifier, List<Expense>>(
  ExpenseNotifier.new,
);

// ============================================================================
// Settlement History Notifier
// ============================================================================

class SettlementHistoryNotifier extends AsyncNotifier<List<SettlementBatch>> {
  late final ExpensesRepository repository;

  @override
  Future<List<SettlementBatch>> build() async {
    repository = ref.watch(expensesRepositoryProvider);
    return _loadHistory();
  }

  Future<List<SettlementBatch>> _loadHistory() async {
    final project = ref.read(projectProvider);
    if (project == null) return [];
    return repository.getSettlementBatches(project.id);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadHistory());
  }
}

final settlementHistoryProvider =
    AsyncNotifierProvider<SettlementHistoryNotifier, List<SettlementBatch>>(
      SettlementHistoryNotifier.new,
    );
