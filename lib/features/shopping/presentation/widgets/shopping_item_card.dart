import 'package:flutter/material.dart';
import 'package:moving_tool_flutter/features/shopping/domain/entities/shopping_item.dart';

class ShoppingItemCard extends StatelessWidget {
  final ShoppingItem item;
  final Function(ShoppingStatus) onStatusChange;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ShoppingItemCard({
    super.key,
    required this.item,
    required this.onStatusChange,
    required this.onDelete,
    required this.onEdit,
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
              onTap: onEdit,
              child: const Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Bewerken'),
                ],
              ),
            ),
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
