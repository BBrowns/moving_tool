import 'package:flutter/material.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/packing_box.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/box_item.dart';
import 'package:moving_tool_flutter/core/widgets/responsive_wrapper.dart'; // Assuming responsive extensions are here or in app_theme

class BoxCard extends StatelessWidget {
  final PackingBox box;
  final List<BoxItem> items;
  final VoidCallback onAddItem;
  final VoidCallback onDeleteBox;
  final VoidCallback onEditBox;
  final Function(BoxItem) onEditItem;

  const BoxCard({
    super.key,
    required this.box,
    required this.items,
    required this.onAddItem,
    required this.onDeleteBox,
    required this.onEditBox,
    required this.onEditItem,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(
          box.isFragile ? Icons.broken_image_outlined : Icons.inventory_2_outlined,
          color: box.isFragile ? AppTheme.error : AppTheme.primary,
        ),
        title: Text(box.label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${items.length} items'),
        childrenPadding: const EdgeInsets.all(16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Nog geen items in deze doos',
                style: TextStyle(color: context.colors.onSurfaceVariant, fontStyle: FontStyle.italic),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) => ActionChip(
                label: Text(item.name),
                backgroundColor: context.colors.surfaceContainerHighest,
                onPressed: () => onEditItem(item),
              )).toList(),
            ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: onDeleteBox,
                icon: const Icon(Icons.delete, size: 18, color: AppTheme.error),
                label: const Text('Verwijderen', style: TextStyle(color: AppTheme.error)),
              ),
              TextButton.icon(
                onPressed: onEditBox,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Bewerken'),
              ),
              FilledButton.icon(
                onPressed: onAddItem,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Item toevoegen'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
