import 'package:flutter/material.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/core/widgets/responsive_wrapper.dart';
import 'package:moving_tool_flutter/features/expenses/domain/entities/expense.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';

class ExpenseSummary extends StatelessWidget {
  final double total;
  final List<Expense> expenses;
  final List<User> users;
  final List<Settlement> settlements;

  const ExpenseSummary({
    super.key,
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
      child: ResponsiveWrapper(
        maxWidth: 800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total
            Card(
              color: AppTheme.primary.withValues(alpha: 0.1),
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
      ),
    );
  }
}
