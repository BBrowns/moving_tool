import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moving_tool_flutter/features/shopping/presentation/providers/shopping_providers.dart';
import 'package:moving_tool_flutter/features/shopping/domain/entities/shopping_item.dart';
import 'package:moving_tool_flutter/features/shopping/presentation/widgets/shopping_item_card.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/core/widgets/responsive_scaffold.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

    return ResponsiveScaffold(
      title: 'Shopping',
      fabLabel: 'Item',
      fabIcon: Icons.add,
      onFabPressed: () => _showItemDialog(context, ref),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Chip(label: Text('${items.length} items')),
        ),
      ],
      body: isWide
          ? _buildKanbanView(context, ref, itemsByStatus)
          : _buildListView(context, ref, items),
    );
  }

  Widget _buildKanbanView(BuildContext context, WidgetRef ref, Map<ShoppingStatus, List<ShoppingItem>> itemsByStatus) {
    return Row(
      children: ShoppingStatus.values.map((status) => Expanded(
        child: DragTarget<ShoppingItem>(
          onWillAcceptWithDetails: (details) => details.data.status != status,
          onAcceptWithDetails: (details) => ref.read(shoppingProvider.notifier).updateStatus(details.data.id, status),
          builder: (context, candidateData, rejectedData) {
            return Container(
              margin: const EdgeInsets.all(8),
              child: Card(
                color: candidateData.isNotEmpty ? _statusColor(status).withValues(alpha: 0.1) : null,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          Text(status.icon, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              status.label, 
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
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
                          final card = ShoppingItemCard(
                            item: item,
                            onStatusChange: (newStatus) => ref.read(shoppingProvider.notifier).updateStatus(item.id, newStatus),
                            onDelete: () => ref.read(shoppingProvider.notifier).delete(item.id),
                            onEdit: () => _showItemDialog(context, ref, item: item),
                          );

                          return Draggable<ShoppingItem>(
                            data: item,
                            feedback: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(width: 300, child: card),
                            ),
                            childWhenDragging: Opacity(opacity: 0.3, child: card),
                            child: card,
                          ).animate().fade(duration: 400.ms, delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
              return ShoppingItemCard(
                item: item,
                onStatusChange: (newStatus) => ref.read(shoppingProvider.notifier).updateStatus(item.id, newStatus),
                onDelete: () => ref.read(shoppingProvider.notifier).delete(item.id),
                onEdit: () => _showItemDialog(context, ref, item: item),
              ).animate().fade(duration: 400.ms, delay: (index * 50).ms).slideX(begin: -0.1, end: 0);
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

  void _showItemDialog(BuildContext context, WidgetRef ref, {ShoppingItem? item}) {
    final isEditing = item != null;
    final nameController = TextEditingController(text: item?.name);
    ShoppingPriority priority = item?.priority ?? ShoppingPriority.medium;

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
            Text(
              isEditing ? 'Item bewerken' : 'Nieuw item', 
              style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              autofocus: !isEditing,
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
                  if (isEditing) {
                    ref.read(shoppingProvider.notifier).update(
                      item!.copyWith(
                        name: nameController.text,
                        priority: priority,
                      )
                    );
                  } else {
                    ref.read(shoppingProvider.notifier).add(
                      name: nameController.text,
                      priority: priority,
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(isEditing ? 'Opslaan' : 'Toevoegen'),
            ),
          ],
        ),
      ),
    );
  }
}
