// Costs Screen - Expense tracking and settlements
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/providers.dart';
import '../../data/models/models.dart';
import '../../core/theme/app_theme.dart';

class CostsScreen extends ConsumerWidget {
  const CostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);
    final project = ref.watch(projectProvider);
    
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final users = project?.users ?? [];
    
    // Calculate settlements
    final settlements = users.isNotEmpty 
        ? calculateSettlements(expenses, users.map((u) => u.id).toList())
        : <Settlement>[];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kosten'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Uitgaven'),
              Tab(text: 'Overzicht'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ExpenseList(
              expenses: expenses,
              users: users,
              onDelete: (id) => ref.read(expenseProvider.notifier).delete(id),
            ),
            _Summary(
              total: totalExpenses,
              expenses: expenses,
              users: users,
              settlements: settlements,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddExpenseDialog(context, ref, users),
          icon: const Icon(Icons.add),
          label: const Text('Uitgave'),
        ),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context, WidgetRef ref, List<User> users) {
    final descController = TextEditingController();
    final amountController = TextEditingController();
    ExpenseCategory category = ExpenseCategory.overig;
    String? paidBy = users.isNotEmpty ? users.first.id : null;
    List<String> splitBetween = users.map((u) => u.id).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16, right: 16, top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Nieuwe uitgave', style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Omschrijving', hintText: 'Waarvoor betaald?'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Bedrag', prefixText: '€ '),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ExpenseCategory>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Categorie'),
                  items: ExpenseCategory.values.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.label),
                  )).toList(),
                  onChanged: (v) => category = v!,
                ),
                if (users.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: paidBy,
                    decoration: const InputDecoration(labelText: 'Betaald door'),
                    items: users.map((u) => DropdownMenuItem(
                      value: u.id,
                      child: Text(u.name),
                    )).toList(),
                    onChanged: (v) => paidBy = v,
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text);
                    if (descController.text.isNotEmpty && amount != null && paidBy != null) {
                      ref.read(expenseProvider.notifier).add(
                        description: descController.text,
                        amount: amount,
                        category: category,
                        paidById: paidBy!,
                        splitBetweenIds: splitBetween,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Toevoegen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final List<User> users;
  final Function(String) onDelete;

  const _ExpenseList({
    required this.expenses,
    required this.users,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💰', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('Nog geen uitgaven', style: context.textTheme.titleLarge),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        final payer = users.where((u) => u.id == expense.paidById).firstOrNull;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Text(expense.category.icon, style: const TextStyle(fontSize: 24)),
            title: Text(expense.description),
            subtitle: Text(payer != null ? 'Betaald door ${payer.name}' : ''),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '€${expense.amount.toStringAsFixed(2)}',
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${expense.date.day}-${expense.date.month}',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Summary extends StatelessWidget {
  final double total;
  final List<Expense> expenses;
  final List<User> users;
  final List<Settlement> settlements;

  const _Summary({
    required this.total,
    required this.expenses,
    required this.users,
    required this.settlements,
  });

  @override
  Widget build(BuildContext context) {
    // Group by category
    final byCategory = <ExpenseCategory, double>{};
    for (final expense in expenses) {
      byCategory[expense.category] = (byCategory[expense.category] ?? 0) + expense.amount;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total
          Card(
            color: AppTheme.primary.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Totaal uitgegeven'),
                  Text(
                    '€${total.toStringAsFixed(2)}',
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          Text('Per categorie', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...byCategory.entries.map((entry) => ListTile(
            leading: Text(entry.key.icon, style: const TextStyle(fontSize: 24)),
            title: Text(entry.key.label.replaceFirst(RegExp(r'^[^\s]+\s'), '')),
            trailing: Text('€${entry.value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          )),
          
          if (settlements.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Af te rekenen', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...settlements.map((s) {
              final from = users.where((u) => u.id == s.fromUserId).firstOrNull;
              final to = users.where((u) => u.id == s.toUserId).firstOrNull;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.arrow_forward),
                  title: Text('${from?.name ?? "?"} → ${to?.name ?? "?"}'),
                  trailing: Text(
                    '€${s.amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.warning),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
