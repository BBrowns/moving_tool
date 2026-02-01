// Dashboard Screen - Main overview with stats
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moving_tool_flutter/data/providers/providers.dart';
import 'package:moving_tool_flutter/data/models/models.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    final tasks = ref.watch(taskProvider);
    final boxes = ref.watch(boxProvider);
    final shopping = ref.watch(shoppingProvider);
    final expenses = ref.watch(expenseProvider);
    final journal = ref.watch(journalProvider);

    if (project == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Stats
    final completedTasks = tasks.where((t) => t.status.name == 'done').length;
    final packedBoxes = boxes.where((b) => b.status.name == 'packed' || b.status.name == 'moved').length;
    final purchasedItems = shopping.where((s) => s.status.name == 'purchased').length;
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text('Hallo!', style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            'Nog ${project.daysUntilMove} dagen tot de verhuizing',
            style: context.textTheme.bodyLarge?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                icon: '✅',
                label: 'Taken',
                value: '$completedTasks/${tasks.length}',
                color: AppTheme.success,
              ),
              _StatCard(
                icon: '📦',
                label: 'Dozen',
                value: '$packedBoxes/${boxes.length}',
                color: AppTheme.primary,
              ),
              _StatCard(
                icon: '🛒',
                label: 'Inkopen',
                value: '$purchasedItems/${shopping.length}',
                color: AppTheme.warning,
              ),
              _StatCard(
                icon: '💰',
                label: 'Kosten',
                value: '€${totalExpenses.toStringAsFixed(0)}',
                color: AppTheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text('Snelle acties', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _QuickActionButton(icon: Icons.add_task, label: 'Taak', onTap: () {}),
                _QuickActionButton(icon: Icons.add_box, label: 'Doos', onTap: () {}),
                _QuickActionButton(icon: Icons.add_shopping_cart, label: 'Inkoop', onTap: () {}),
                _QuickActionButton(icon: Icons.receipt_long, label: 'Uitgave', onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Activity
          if (journal.isNotEmpty) ...[
            Text('Recente activiteit', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: journal.take(5).map((entry) => ListTile(
                  leading: Text(entry.type.icon, style: const TextStyle(fontSize: 20)),
                  title: Text(entry.title),
                  subtitle: Text(_formatDate(entry.timestamp)),
                  dense: true,
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m geleden';
    if (diff.inHours < 24) return '${diff.inHours}u geleden';
    if (diff.inDays < 7) return '${diff.inDays}d geleden';
    return '${date.day}/${date.month}';
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(label, style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
              ],
            ),
            Text(
              value,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
