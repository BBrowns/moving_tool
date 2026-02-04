import 'package:flutter/material.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/box_item.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/packing_box.dart';
import 'package:moving_tool_flutter/features/packing/presentation/extensions/box_display_extension.dart';

class BoxCard extends StatelessWidget {

  const BoxCard({
    required this.box, required this.items, required this.onAddItem, required this.onDeleteBox, required this.onEditBox, required this.onEditItem, required this.onToggleItem, required this.onToggleBox, super.key,
  });
  final PackingBox box;
  final List<BoxItem> items;
  final VoidCallback onAddItem;
  final VoidCallback onDeleteBox;
  final VoidCallback onEditBox;
  final void Function(BoxItem) onEditItem;
  final void Function(BoxItem) onToggleItem;
  final VoidCallback onToggleBox;

  @override
  Widget build(BuildContext context) {
    // Status Logic
    final isPacked = box.status == BoxStatus.packed;

    // Determine Icon
    final icon = box.displayIcon;
    final iconColor = box.displayColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isPacked
          ? context.colors.surfaceContainerLow
          : null, // Dimmed if packed
      child: ExpansionTile(
        leading: IconButton(
          icon: Icon(icon, color: iconColor),
          onPressed: onToggleBox,
          tooltip: isPacked
              ? 'Markeren als niet ingepakt'
              : 'Markeren als ingepakt',
        ),
        title: Text(
          box.label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isPacked ? TextDecoration.lineThrough : null,
            color: isPacked ? Colors.grey : null,
          ),
        ),
        subtitle: Text('${items.length} items'),
        childrenPadding: const EdgeInsets.all(16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Nog geen items in deze doos',
                style: TextStyle(
                  color: context.colors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items
                  .map(
                    (item) => InputChip(
                      label: Text(
                        item.name,
                        style: TextStyle(
                          decoration: item.isPacked
                              ? TextDecoration.lineThrough
                              : null,
                          color: item.isPacked ? Colors.grey : null,
                        ),
                      ),
                      selected: item.isPacked,
                      showCheckmark: true,
                      onSelected: (_) => onToggleItem(item),
                      onDeleted: () => onEditItem(item),
                      deleteIcon: const Icon(Icons.edit, size: 14),
                      deleteButtonTooltipMessage: 'Bewerken',
                      backgroundColor: context.colors.surfaceContainerHighest,
                      selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                      checkmarkColor: AppTheme.primary,
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: onDeleteBox,
                icon: const Icon(Icons.delete, size: 18, color: AppTheme.error),
                label: const Text(
                  'Verwijderen',
                  style: TextStyle(color: AppTheme.error),
                ),
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
