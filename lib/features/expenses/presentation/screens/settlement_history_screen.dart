import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:moving_tool_flutter/features/expenses/domain/entities/settlement_batch.dart';
import 'package:moving_tool_flutter/features/expenses/presentation/providers/expense_providers.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';
import 'package:moving_tool_flutter/features/projects/presentation/providers/project_providers.dart';

class SettlementHistoryScreen extends ConsumerWidget {
  const SettlementHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(settlementHistoryProvider);
    final project = ref.read(projectProvider);
    final users = project?.users ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verrekeningen Geschiedenis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(settlementHistoryProvider.notifier).refresh(),
          ),
        ],
      ),
      body: historyAsync.when(
        data: (List<SettlementBatch> batches) {
          if (batches.isEmpty) {
            return const Center(
              child: Text(
                'Geen eerdere verrekeningen gevonden.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          // Sort by date descending
          final sortedBatches = List<SettlementBatch>.from(batches)
            ..sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            itemCount: sortedBatches.length,
            itemBuilder: (context, index) {
              final batch = sortedBatches[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal[100],
                    child: const Icon(Icons.receipt_long, color: Colors.teal),
                  ),
                  title: Text(
                    DateFormat('d MMMM yyyy, HH:mm').format(batch.date),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Totaal verrekend: €${batch.totalAmount.toStringAsFixed(2)}',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (batch.settlements.isEmpty)
                            const Text('Geen betalingen nodig.')
                          else
                            ...batch.settlements.map((s) {
                              final fromUser = users.cast<User>().firstWhere(
                                (u) => u.id == s.fromUserId,
                                orElse: () =>
                                    User(id: '', name: '?', color: 'Grey'),
                              );
                              final toUser = users.cast<User>().firstWhere(
                                (u) => u.id == s.toUserId,
                                orElse: () =>
                                    User(id: '', name: '?', color: 'Grey'),
                              );

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      fromUser.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(' betaalt '),
                                    Text(
                                      '€${s.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(' aan '),
                                    Text(
                                      toUser.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verrekende uitgaven',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          if (batch.expenseIds.isEmpty)
                            const Text(
                              'Geen uitgaven gevonden voor deze verrekening.',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            )
                          else
                            ...ref
                                .read(expenseProvider)
                                .where((e) => batch.expenseIds.contains(e.id))
                                .map((expense) {
                                  final payer = users.cast<User>().firstWhere(
                                    (u) => u.id == expense.paidById,
                                    orElse: () =>
                                        User(id: '', name: '?', color: 'Grey'),
                                  );
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          DateFormat(
                                            'd MMM',
                                          ).format(expense.date),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(expense.description),
                                        ),
                                        Text(
                                          '€${expense.amount.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '(${payer.name})',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Fout bij laden: $err')),
      ),
    );
  }
}
