import 'package:flutter/material.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/core/widgets/responsive_wrapper.dart';
import 'package:moving_tool_flutter/features/expenses/domain/entities/expense.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final List<User> users;
  final Function(String) onDelete;
  final Function(Expense) onEdit;

  const ExpenseList({
    super.key,
    required this.expenses,
    required this.users,
    required this.onDelete,
    required this.onEdit,
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

    return ResponsiveWrapper(
      maxWidth: 800,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          final payer = users.where((u) => u.id == expense.paidById).firstOrNull;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              onTap: () => onEdit(expense),
              leading: Text(expense.category.icon, style: const TextStyle(fontSize: 24)),
              title: Text(expense.description),
              subtitle: Text(payer != null ? 'Betaald door ${payer.name}' : ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
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
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                    onPressed: () => onDelete(expense.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
