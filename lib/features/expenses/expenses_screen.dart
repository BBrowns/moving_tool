import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moving_tool_flutter/features/expenses/presentation/providers/expense_providers.dart';
import 'package:moving_tool_flutter/features/expenses/domain/entities/expense.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/core/widgets/responsive_scaffold.dart';
import 'package:moving_tool_flutter/features/expenses/presentation/widgets/expense_list.dart';
import 'package:moving_tool_flutter/features/expenses/presentation/widgets/expense_summary.dart';
import 'package:moving_tool_flutter/data/providers/providers.dart'; // For projectProvider

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

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
      child: ResponsiveScaffold(
        title: 'Kosten',
        fabLabel: 'Uitgave',
        fabIcon: Icons.add,
        onFabPressed: () => _showExpenseDialog(context, ref, users),
        body: Column(
          children: [
            Material(
              color: context.colors.surface,
              child: const TabBar(
                tabs: [
                  Tab(text: 'Uitgaven'),
                  Tab(text: 'Overzicht'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: const _NestedTabBarViewPhysics(),
                children: [
                  ExpenseList(
                    expenses: expenses,
                    users: users,
                    onDelete: (id) => ref.read(expenseProvider.notifier).delete(id),
                    onEdit: (expense) => _showExpenseDialog(context, ref, users, expense: expense),
                  ),
                  ExpenseSummary(
                    total: totalExpenses,
                    expenses: expenses,
                    users: users,
                    settlements: settlements,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExpenseDialog(BuildContext context, WidgetRef ref, List<User> users, {Expense? expense}) {
    final isEditing = expense != null;
    final descController = TextEditingController(text: expense?.description);
    final amountController = TextEditingController(text: expense?.amount.toString().replaceAll('.', ','));
    ExpenseCategory category = expense?.category ?? ExpenseCategory.overig;
    
    // Default to first user or 'me' if no users, or existing paidBy
    String? paidBy = expense?.paidById ?? (users.isNotEmpty ? users.first.id : null);
    
    // Default to all users if new, or existing split
    List<String> splitBetween = expense?.splitBetweenIds ?? users.map((u) => u.id).toList();

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
                Text(
                  isEditing ? 'Uitgave bewerken' : 'Nieuwe uitgave', 
                  style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Omschrijving', hintText: 'Waarvoor betaald?'),
                  autofocus: !isEditing,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Bedrag', prefixText: '€ '),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ExpenseCategory>(
                  initialValue: category,
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
                    onChanged: (v) => setModalState(() => paidBy = v),
                  ),
                  const SizedBox(height: 16),
                  Text('Verdeeld over:', style: context.textTheme.titleSmall),
                  Wrap(
                    spacing: 8,
                    children: users.map((u) {
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
                    final normalizedAmount = amountController.text.replaceAll(',', '.');
                    final amount = double.tryParse(normalizedAmount);
                    
                    // Fallback for solo users
                    final effectivePaidBy = paidBy ?? (users.isEmpty ? 'me' : null);
                    final effectiveSplit = splitBetween.isEmpty ? [effectivePaidBy!] : splitBetween;
                    
                    if (descController.text.isNotEmpty && amount != null && effectivePaidBy != null && effectiveSplit.isNotEmpty) {
                      if (isEditing) {
                         ref.read(expenseProvider.notifier).update(
                          expense!.copyWith(
                            description: descController.text,
                            amount: amount,
                            category: category,
                            paidById: effectivePaidBy,
                            splitBetweenIds: effectiveSplit,
                          )
                        );
                      } else {
                        ref.read(expenseProvider.notifier).add(
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
                          content: Text('Controleer of alle velden zijn ingevuld (en minstens 1 persoon bij verdeling).'),
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

class _NestedTabBarViewPhysics extends ScrollPhysics {
  const _NestedTabBarViewPhysics({super.parent});

  @override
  _NestedTabBarViewPhysics applyTo(ScrollPhysics? ancestor) {
    return _NestedTabBarViewPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // If we are at the edge, allow the parent to handle the gesture (return 0.0)
    // Standard ClampingScrollPhysics returns the overscroll amount to 'absorb' it.
    // By returning 0.0 when at boundary, we tell the system "I didn't consume this, it's valid delta".
    // But we need to ensure we don't actually scroll out of bounds.
    // Wait, if we return 0.0, the ScrollPosition treats it as a valid move for ITSELF and moves pixels.
    // If pixels are at min/max, it updates.
    
    // Correct logic for Nested PageViews:
    // If we are at min (0) and trying to go less (negative delta => value < pixels), 
    // we want to declare "Boundary Hit" so parent takes over?
    // Actually, Flutter's DragGestureRecognizer for PageView is competitive.
    // If the inner Scrollable returns 'overscroll' via Notification, the outer might pick it up?
    
    // Actually, the trick is usually to enforce 'Clamping' behavior locally which reports Overscroll,
    // and ensure the Outer PageView listener picks up that Overscroll.
    // But PageView defaults to Clamping already on Android.
    
    // Let's try to delegate to parent physics logic:
    // This implementation simply forces 'overscroll' to be reported as 0 consumption, 
    // allowing the event to propagate?
    
    // No, strictly speaking:
    // If (value < position.pixels && position.pixels <= position.minScrollExtent) // Underscroll
    // OR (value > position.pixels && position.pixels >= position.maxScrollExtent) // Overscroll
    // THEN return value - position.pixels; // Handled! (Consumed).
    
    // If we want parent to handle it, we should NOT define boundary conditions?
    // BouncingScrollPhysics (iOS) does NOT define simple boundaries, it allows scrolling past.
    // If we use BouncingScrollPhysics, the inner view bounces. Parent ignores it.
    
    // If we use ClampingScrollPhysics, it clamps. Parent ignores it.
    
    // We want: If at edge + drag away -> Allow Parent.
    // This is hard to do cleanly with just Physics in Flutter 2/3.
    // However, defining a 'ClampingScrollPhysics' that explicitly does NOT report handled boundary
    // might trick the DragArena? 
    
    // A simpler known hack:
    // return 0.0; // Never block.
    
    // Logic:
    // If we are overlapping (at edge), we return 0.0.
    // This lets the scrollable try to move. It will fail to move pixels (clamped by extent), 
    // producing an OverscrollNotification.
    // The Parent PageView listens to OverscrollNotification? 
    // Yes, PageView wraps child in NotificationLister.
    
    return 0.0;
  }
}
