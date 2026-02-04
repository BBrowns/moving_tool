import 'package:flutter/material.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/features/shopping/domain/entities/shopping_item.dart';
import 'package:url_launcher/url_launcher.dart';

class ShoppingItemCard extends StatelessWidget {

  const ShoppingItemCard({
    required this.item, required this.onStatusChange, required this.onDelete, required this.onEdit, super.key,
  });
  final ShoppingItem item;
  final void Function(ShoppingStatus) onStatusChange;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  
  Future<void> _launchMarktplaats() async {
    final query = item.marktplaatsQuery?.trim().isNotEmpty == true 
        ? item.marktplaatsQuery! 
        : item.name;
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('https://www.marktplaats.nl/q/$encodedQuery/');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(item.status.icon, size: 24, color: AppTheme.primary),
        title: Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.budgetMax != null)
              Text(
                'Budget: €${item.budgetMin?.toStringAsFixed(0) ?? "0"} - €${item.budgetMax!.toStringAsFixed(0)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (item.isMarktplaatsTracked && item.targetPrice != null)
              Text(
                'Doelprijs: €${item.targetPrice!.toStringAsFixed(0)}',
                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w500),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.isMarktplaatsTracked)
              IconButton(
                icon: const Icon(Icons.saved_search, color: AppTheme.primary),
                tooltip: 'Zoek op Marktplaats',
                onPressed: _launchMarktplaats,
              ),
            PopupMenuButton<ShoppingStatus>(
              icon: const Icon(Icons.more_vert),
              onSelected: onStatusChange,
              itemBuilder: (context) => [
                ...ShoppingStatus.values.map((s) => PopupMenuItem(
                  value: s,
                  child: Row(
                    children: [
                      Icon(s.icon, size: 20),
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
          ],
        ),
      ),
    );
  }
}
