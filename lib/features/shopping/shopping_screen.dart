// Shopping Screen - Kanban-style shopping list
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/providers.dart';
import '../../data/models/models.dart';
import '../../core/theme/app_theme.dart';

class ShoppingScreen extends ConsumerWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(shoppingProvider);
    final isWide = MediaQuery.of(context).size.width > 800;

    // Group by status
    final itemsByStatus = <ShoppingStatus, List<ShoppingItem>>{};
    for (final status in ShoppingStatus.values) {
      itemsByStatus[status] = items.where((i) => i.status == status).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(label: Text('${items.length} items')),
          ),
        ],
      ),
      body: isWide
          ? _buildKanbanView(context, ref, itemsByStatus)
          : _buildListView(context, ref, items),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Item'),
      ),
    );
  }

  Widget _buildKanbanView(BuildContext context, WidgetRef ref, Map<ShoppingStatus, List<ShoppingItem>> itemsByStatus) {
    return Row(
      children: ShoppingStatus.values.map((status) => Expanded(
        child: Container(
          margin: const EdgeInsets.all(8),
          child: Card(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Text(status.icon, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(status.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _statusColor(status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${itemsByStatus[status]?.length ?? 0}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: itemsByStatus[status]?.length ?? 0,
                    itemBuilder: (context, index) {
                      final item = itemsByStatus[status]![index];
                      return _ShoppingItemCard(
                        item: item,
                        onStatusChange: (newStatus) => ref.read(shoppingProvider.notifier).updateStatus(item.id, newStatus),
                        onDelete: () => ref.read(shoppingProvider.notifier).delete(item.id),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildListView(BuildContext context, WidgetRef ref, List<ShoppingItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🛒', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('Nog geen items', style: context.textTheme.titleLarge),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _ShoppingItemCard(
          item: item,
          onStatusChange: (newStatus) => ref.read(shoppingProvider.notifier).updateStatus(item.id, newStatus),
          onDelete: () => ref.read(shoppingProvider.notifier).delete(item.id),
        );
      },
    );
  }

  Color _statusColor(ShoppingStatus status) {
    switch (status) {
      case ShoppingStatus.needed: return AppTheme.error;
      case ShoppingStatus.searching: return AppTheme.warning;
      case ShoppingStatus.found: return AppTheme.primary;
      case ShoppingStatus.purchased: return AppTheme.success;
    }
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    ShoppingPriority priority = ShoppingPriority.medium;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16, right: 16, top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Nieuw item', style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Naam', hintText: 'Wat heb je nodig?'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ShoppingPriority>(
              value: priority,
              decoration: const InputDecoration(labelText: 'Prioriteit'),
              items: ShoppingPriority.values.map((p) => DropdownMenuItem(
                value: p,
                child: Text(p.label),
              )).toList(),
              onChanged: (v) => priority = v!,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  ref.read(shoppingProvider.notifier).add(
                    name: nameController.text,
                    priority: priority,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Toevoegen'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShoppingItemCard extends StatelessWidget {
  final ShoppingItem item;
  final Function(ShoppingStatus) onStatusChange;
  final VoidCallback onDelete;

  const _ShoppingItemCard({
    required this.item,
    required this.onStatusChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(item.status.icon, style: const TextStyle(fontSize: 24)),
        title: Text(item.name),
        subtitle: item.budgetMax != null 
            ? Text('Budget: €${item.budgetMin?.toStringAsFixed(0) ?? "0"} - €${item.budgetMax!.toStringAsFixed(0)}')
            : null,
        trailing: PopupMenuButton<ShoppingStatus>(
          icon: const Icon(Icons.more_vert),
          onSelected: onStatusChange,
          itemBuilder: (context) => [
            ...ShoppingStatus.values.map((s) => PopupMenuItem(
              value: s,
              child: Row(
                children: [
                  Text(s.icon),
                  const SizedBox(width: 8),
                  Text(s.label),
                ],
              ),
            )),
            const PopupMenuDivider(),
            PopupMenuItem(
              onTap: onDelete,
              child: const Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Verwijderen', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
