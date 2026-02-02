import 'package:flutter/material.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/room.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/packing_box.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/box_item.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final List<PackingBox> boxes;
  final List<BoxItem> items; // Keeping for total count if needed, or derived
  final VoidCallback onAddBox;
  final VoidCallback onDeleteRoom;
  final VoidCallback onTap;

  const RoomCard({
    super.key,
    required this.room,
    required this.boxes,
    required this.items,
    required this.onAddBox,
    required this.onDeleteRoom,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final packedCount = boxes.where((b) => b.status == BoxStatus.packed).length;
    final progress = boxes.isEmpty ? 0.0 : packedCount / boxes.length;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: context.isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: context.isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(room.icon, style: const TextStyle(fontSize: 24)),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_box_outlined, size: 20),
                        onPressed: onAddBox,
                        tooltip: 'Doos toevoegen',
                        style: IconButton.styleFrom(
                          backgroundColor: context.colors.surfaceContainerHighest,
                        ),
                      ),
                      const SizedBox(width: 4),
                       IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.error),
                        onPressed: onDeleteRoom,
                        tooltip: 'Verwijder kamer',
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),
              Text(
                room.name,
                style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Note: items.length might be misleading if it's GLOBAL items.
              // Ideally this card should only receive items for this room/boxes. 
              // But for now matching legacy behavior which seemed to pass all items.
              Text(
                '${boxes.length} dozen • ${items.length} items', 
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              // Progress Bar
              if (boxes.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ingepakt', style: context.textTheme.labelSmall),
                    Text('${(progress * 100).toInt()}%', style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: context.colors.surfaceContainerHighest,
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ] else 
                 Container(
                   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                   child: Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Icon(Icons.info_outline, size: 16, color: context.colors.onSurfaceVariant),
                       const SizedBox(width: 8),
                       Text('Nog geen dozen', style: context.textTheme.bodySmall),
                     ],
                   ),
                 )
            ],
          ),
        ),
      ),
    );
  }
}
