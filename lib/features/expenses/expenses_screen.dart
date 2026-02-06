import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/core/widgets/responsive_scaffold.dart';
import 'package:moving_tool_flutter/core/widgets/responsive_wrapper.dart';
import 'package:moving_tool_flutter/data/providers/providers.dart'; // For projectProvider
import 'package:moving_tool_flutter/features/expenses/domain/entities/expense.dart';
import 'package:moving_tool_flutter/features/expenses/presentation/screens/settlement_history_screen.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);
    final project = ref.watch(projectProvider);

    // Filter out settled expenses for the main view
    final openExpenses = expenses.where((e) => e.settlementId == null).toList();

    final totalExpenses = ref
        .read(expenseProvider.notifier)
        .totalExpenses; // Use getter we updated
    final members = project?.members ?? [];

    // Sort expenses by date (newest first)
    final sortedExpenses = List<Expense>.from(openExpenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Calculate settlements for OPEN expenses only
    final settlements = members.isNotEmpty
        ? calculateSettlements(openExpenses, members.map((u) => u.id).toList())
        : <Settlement>[];

    return ResponsiveScaffold(
      fabHeroTag: 'expenses_fab',
      title: 'Kosten',
      actions: [
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const SettlementHistoryScreen(),
            ),
          ),
          icon: const Icon(Icons.history),
          tooltip: 'Geschiedenis',
        ),
        IconButton(
          onPressed: () =>
              _showSettlementDialog(context, ref, settlements, members),
          icon: const Icon(Icons.handshake_outlined), // Changed to handshake
          tooltip: 'Verrekenen',
        ),
      ],
      fabLabel: 'Uitgave',
      fabIcon: Icons.add,
      onFabPressed: () => _showExpenseDialog(context, ref, members),
      body: ResponsiveWrapper(
        maxWidth: 800,
        child: CustomScrollView(
          slivers: [
            // Balance Header
            SliverToBoxAdapter(
              child: _BalanceHeader(
                total: totalExpenses,
                members: members,
                expenses: openExpenses,
              ),
            ),

            // Transaction List
            if (openExpenses.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.savings_outlined,
                        size: 80,
                        color: context.colors.primary.withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nog geen uitgaven',
                        style: context.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Voeg de eerste uitgave toe',
                        style: TextStyle(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final expense = sortedExpenses[index];
                    final showHeader =
                        index == 0 ||
                        !DateUtils.isSameDay(
                          sortedExpenses[index - 1].date,
                          expense.date,
                        );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader) _DateHeader(date: expense.date),
                        _ExpenseTile(
                          expense: expense,
                          members: members,
                          onTap: () => _showExpenseDialog(
                            context,
                            ref,
                            members,
                            expense: expense,
                          ),
                        ),
                      ],
                    );
                  }, childCount: sortedExpenses.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSettlementDialog(
    BuildContext context,
    WidgetRef ref,
    List<Settlement> settlements,
    List<ProjectMember> members,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Verrekenen',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (settlements.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: Colors.green.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Alles is verrekend!',
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyLarge,
                    ),
                  ],
                ),
              )
            else ...[
              ...settlements.map((settlement) {
                final fromUser = members.cast<ProjectMember>().firstWhere(
                  (u) => u.id == settlement.fromUserId,
                  orElse: () => const ProjectMember(
                    id: '',
                    name: 'Onbekend',
                    role: ProjectRole.viewer,
                    color: '#808080',
                  ),
                );
                final toUser = members.cast<ProjectMember>().firstWhere(
                  (u) => u.id == settlement.toUserId,
                  orElse: () => const ProjectMember(
                    id: '',
                    name: 'Onbekend',
                    role: ProjectRole.viewer,
                    color: '#808080',
                  ),
                );

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(child: Text(fromUser.name[0])),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: context.textTheme.bodyLarge,
                            children: [
                              TextSpan(text: '${fromUser.name} '),
                              const TextSpan(text: 'betaalt '),
                              TextSpan(
                                text:
                                    '€${settlement.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.error,
                                ),
                              ),
                              const TextSpan(text: ' aan '),
                              TextSpan(text: toUser.name),
                            ],
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: Colors.grey),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Bevestig Verrekening'),
                      content: const Text(
                        'Weet je zeker dat je wilt verrekenen? Alle huidige uitgaven worden als "betaald" gemarkeerd en de balans gaat naar 0.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: const Text('Annuleren'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: const Text('Verrekenen'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    // For now, attribute to the first user or a system user
                    // In a real app, this would be the logged-in user
                    final creatorId = members.isNotEmpty
                        ? members.first.id
                        : 'unknown';
                    await ref
                        .read(expenseProvider.notifier)
                        .settleUp(
                          members.map((u) => u.id).toList(),
                          createdByUserId: creatorId,
                        );
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Verrekenen & Balans resetten'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green, // Distinctive color
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
            if (settlements.isEmpty)
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Sluiten'),
              ),
          ],
        ),
      ),
    );
  }

  void _showExpenseDialog(
    BuildContext context,
    WidgetRef ref,
    List<ProjectMember> members, {
    Expense? expense,
  }) {
    final isEditing = expense != null;
    final descController = TextEditingController(text: expense?.description);
    final amountController = TextEditingController(
      text: expense?.amount.toString().replaceAll('.', ','),
    );
    ExpenseCategory category = expense?.category ?? ExpenseCategory.overig;

    // Default to first user or 'me' if no users, or existing paidBy
    String? paidBy =
        expense?.paidById ?? (members.isNotEmpty ? members.first.id : null);

    // Default to all users if new, or existing split
    final List<String> splitBetween =
        expense?.splitBetweenIds ?? members.map((u) => u.id).toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEditing ? 'Uitgave bewerken' : 'Nieuwe uitgave',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Omschrijving',
                    hintText: 'Waarvoor betaald?',
                  ),
                  autofocus: !isEditing,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Bedrag',
                    prefixText: '€ ',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ExpenseCategory>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Categorie'),
                  items: ExpenseCategory.values
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Row(
                            children: [
                              Icon(
                                c.icon,
                                size: 18,
                                color: context.colors.onSurface,
                              ),
                              const SizedBox(width: 8),
                              Text(c.label),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => category = v!,
                ),
                if (members.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: paidBy,
                    decoration: const InputDecoration(
                      labelText: 'Betaald door',
                    ),
                    items: members
                        .map(
                          (u) => DropdownMenuItem(
                            value: u.id,
                            child: Text(u.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setModalState(() => paidBy = v),
                  ),
                  const SizedBox(height: 16),
                  Text('Verdeeld over:', style: context.textTheme.titleSmall),
                  Wrap(
                    spacing: 8,
                    children: members.map((u) {
                      final isSelected = splitBetween.contains(u.id);
                      return FilterChip(
                        label: Text(u.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              splitBetween.add(u.id);
                            } else {
                              splitBetween.remove(u.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    final normalizedAmount = amountController.text.replaceAll(
                      ',',
                      '.',
                    );
                    final amount = double.tryParse(normalizedAmount);

                    // Fallback for solo users
                    final effectivePaidBy =
                        paidBy ?? (members.isEmpty ? 'me' : null);
                    final effectiveSplit = splitBetween.isEmpty
                        ? [effectivePaidBy!]
                        : splitBetween;

                    if (descController.text.isNotEmpty &&
                        amount != null &&
                        effectivePaidBy != null &&
                        effectiveSplit.isNotEmpty) {
                      if (isEditing) {
                        ref
                            .read(expenseProvider.notifier)
                            .update(
                              expense.copyWith(
                                description: descController.text,
                                amount: amount,
                                category: category,
                                paidById: effectivePaidBy,
                                splitBetweenIds: effectiveSplit,
                              ),
                            );
                      } else {
                        ref
                            .read(expenseProvider.notifier)
                            .add(
                              description: descController.text,
                              amount: amount,
                              category: category,
                              paidById: effectivePaidBy,
                              splitBetweenIds: effectiveSplit,
                            );
                      }
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Controleer of alle velden zijn ingevuld (en minstens 1 persoon bij verdeling).',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(isEditing ? 'Opslaan' : 'Toevoegen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({
    required this.total,
    required this.members,
    required this.expenses,
  });
  final double total;
  final List<ProjectMember> members;
  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Totaal uitgegeven',
            style: context.textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '€ ${total.toStringAsFixed(2)}',
            style: context.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (members.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: members.map((user) {
                  final paid = expenses
                      .where((e) => e.paidById == user.id)
                      .fold(0.0, (sum, e) => sum + e.amount);

                  return Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 16,
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '€${paid.toStringAsFixed(0)}',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (DateUtils.isSameDay(date, now)) {
      label = 'Vandaag';
    } else if (DateUtils.isSameDay(
      date,
      now.subtract(const Duration(days: 1)),
    )) {
      label = 'Gisteren';
    } else {
      label = DateFormat('d MMMM', 'nl_NL').format(date);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        label.toUpperCase(),
        style: context.textTheme.labelMedium?.copyWith(
          color: context.colors.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.expense,
    required this.members,
    required this.onTap,
  });
  final Expense expense;
  final List<ProjectMember> members;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final payer = members.where((u) => u.id == expense.paidById).firstOrNull;
    final payerName = payer?.name ?? 'Onbekend';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  expense.category.icon,
                  size: 24,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Betaald door $payerName',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '€ ${expense.amount.toStringAsFixed(2)}',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    // Typically 'Splitser' shows positive/neutral for total amounts
                    // If we had 'Your Share', we'd color it red/green.
                    color: context.colors.onSurface,
                  ),
                ),
                // If we have user ID context, we could show "You borrowed €5.00"
              ],
            ),
          ],
        ),
      ),
    );
  }
}
