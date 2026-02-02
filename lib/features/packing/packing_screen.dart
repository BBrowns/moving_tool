import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moving_tool_flutter/core/models/models.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/features/packing/presentation/providers/packing_providers.dart';
import 'package:moving_tool_flutter/features/packing/presentation/widgets/room_card.dart';
import 'package:moving_tool_flutter/features/packing/presentation/widgets/box_card.dart';
import 'package:moving_tool_flutter/core/widgets/responsive_wrapper.dart';
import 'package:moving_tool_flutter/core/widgets/responsive_scaffold.dart';
import 'package:moving_tool_flutter/data/services/llm_service.dart';
import 'package:moving_tool_flutter/data/services/database_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PackingScreen extends ConsumerWidget {
  const PackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch Data
    final rooms = ref.watch(roomProvider);
    final stats = ref.watch(packingStatsProvider);

    return ResponsiveScaffold(
      title: 'Inpakken',
      fabHeroTag: 'packing_fab',
      fabLabel: 'Kamer',
      fabIcon: Icons.add,
      onFabPressed: () => _ShowDialogs.showRoomDialog(context, ref),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Chip(
            avatar: const Icon(Icons.inventory_2, size: 16),
            label: Text('${stats.packedBoxes}/${stats.totalBoxes} dozen • ${stats.totalItems} items'),
          ),
        ),
      ],
      body: ResponsiveWrapper(
        maxWidth: 1200,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: rooms.isEmpty
                  ? SliverToBoxAdapter(child: _buildEmptyState(context, ref))
                  : SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final room = rooms[index];
                          // Efficient filtering via derived provider (not optimal in loop but consistent with design)
                          // Ideally we'd have a separate RoomWidget that takes just ID and watches its own scope,
                          // but passing data is fine for now. 
                          // NOTE: We can't watch family provider in a loop easily without a separate widget.
                          // So we will use a separate widget for the grid item to optimize rebuilds.
                          return _RoomGridItem(room: room).animate().fade(duration: 400.ms, delay: (index * 50).ms).scale(begin: const Offset(0.9, 0.9));
                        },
                        childCount: rooms.length,
                      ),
                    ),
            ),
             const SliverToBoxAdapter(child: SizedBox(height: 80)), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏠', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('Nog geen kamers', style: context.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Voeg kamers toe om te beginnen met inpakken',
            style: TextStyle(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _ShowDialogs.showRoomDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Eerste kamer toevoegen'),
          ),
        ],
      ),
    );
  }

  // No local _showAddRoomDialog needed anymore, use _ShowDialogs.showRoomDialog
}

class _RoomGridItem extends ConsumerWidget {
  final Room room;
  const _RoomGridItem({required this.room});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomBoxes = ref.watch(roomBoxesProvider(room.id));
    // Note: To get "total items" for this room, we'd need to sum items of all boxes.
    // For now, let's keep it simple or fetch all items and filter (expensive but existing behavior).
    // Better: Derived provider for room items. 
    // Optimization: Just count items in these boxes.
    // However, `roomCard` expects List<BoxItem> items. This might be heavy for just a count.
    
    // Let's optimize: We'll calculate item count cheaply if possible, or just pass empty for now if UI only needs count?
    // Looking at RoomCard, it displays: '${items.length} items'.
    // So we need the items.
    
    // We can't easily query "all items for this room" cheaply without a join.
    // Let's fetch all items and filter for now as per previous logic, but strictly speaking this should be optimized later.
    final allItems = ref.watch(boxItemProvider);
    final roomItems = allItems.where((i) {
       // Check if item's box is in this room
       return roomBoxes.any((b) => b.id == i.boxId);
    }).toList();


    return RoomCard(
      room: room,
      boxes: roomBoxes,
      items: roomItems, 
      onAddBox: () => _ShowDialogs.showBoxDialog(context, ref, room.id),
      onDeleteRoom: () => ref.read(roomProvider.notifier).delete(room.id),
      onTap: () => _showRoomDetails(context, ref, room),
    );
  }

  void _showRoomDetails(BuildContext context, WidgetRef ref, Room room) {
     showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        expand: false,
        builder: (context, scrollController) => Scaffold(
          appBar: AppBar(
            title: Text(room.name),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => _showAiSuggestions(context, room.name),
                icon: const Icon(Icons.auto_awesome, color: AppTheme.primary),
                label: const Text('Tips'),
              ),
              IconButton(
                onPressed: () => _ShowDialogs.showRoomDialog(context, ref, room: room),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Kamer bewerken',
              ),
              IconButton(
                onPressed: () => _ShowDialogs.showBoxDialog(context, ref, room.id),
                icon: const Icon(Icons.add_box),
                tooltip: 'Doos toevoegen',
              ),
            ],
          ),
          body: Consumer(
            builder: (context, ref, child) {
              // Now we are inside the detail, we can watch the specific room logic
              final boxes = ref.watch(roomBoxesProvider(room.id));
              
              if (boxes.isEmpty) {
                return Center(
                  child: Text('Nog geen dozen in deze kamer', style: context.textTheme.bodyLarge),
                );
              }

              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: boxes.length,
                itemBuilder: (context, index) {
                  final box = boxes[index];
                  // Use separate widget for BoxItem to optimize
                  return _BoxListItem(box: box);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showAiSuggestions(BuildContext context, String roomName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final apiKey = DatabaseService.getSetting('gemini_api_key');
      final suggestions = await LlmService.suggestPackingList(roomName, apiKey);

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 32),
            title: Text('AI Inpaktips: $roomName'),
            content: SingleChildScrollView(
              child: Text(suggestions),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Sluiten'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fout bij ophalen tips: $e')),
        );
      }
    }
  }
}

class _BoxListItem extends ConsumerWidget {
  final PackingBox box;
  const _BoxListItem({required this.box});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boxItems = ref.watch(boxItemsProvider(box.id));
    
    return BoxCard(
      box: box, 
      items: boxItems,
      onAddItem: () => _ShowDialogs.showItemDialog(context, ref, box.id),
      onDeleteBox: () => ref.read(boxProvider.notifier).delete(box.id),
      onEditBox: () => _ShowDialogs.showBoxDialog(context, ref, box.roomId, box: box),
      onEditItem: (item) => _ShowDialogs.showItemDialog(context, ref, box.id, item: item),
      onToggleItem: (item) => ref.read(boxItemProvider.notifier).togglePacked(item.id),
      onToggleBox: () => ref.read(boxProvider.notifier).toggleBoxPacked(box.id),
    );
  }
}

class _ShowDialogs {
  static void showRoomDialog(BuildContext context, WidgetRef ref, {Room? room}) {
    final isEditing = room != null;
    final nameController = TextEditingController(text: room?.name);
    String selectedIcon = room?.icon ?? '📦';

    final icons = ['🛋️', '🛏️', '🍳', '🚿', '👶', '🧑‍💻', '📦', '🔧'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16, right: 16, top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Kamer bewerken' : 'Nieuwe kamer', 
                style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                autofocus: !isEditing,
                decoration: const InputDecoration(labelText: 'Naam', hintText: 'bijv. Woonkamer'),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: icons.map((icon) => GestureDetector(
                  onTap: () => setModalState(() => selectedIcon = icon),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selectedIcon == icon 
                          ? AppTheme.primary.withValues(alpha: 0.2)
                          : context.colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: selectedIcon == icon 
                          ? Border.all(color: AppTheme.primary, width: 2)
                          : null,
                    ),
                    child: Text(icon, style: const TextStyle(fontSize: 24)),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    if (isEditing) {
                      ref.read(roomProvider.notifier).update(
                        room!.copyWith(
                          name: nameController.text,
                          icon: selectedIcon,
                        )
                      );
                    } else {
                      ref.read(roomProvider.notifier).add(
                        name: nameController.text,
                        icon: selectedIcon,
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
      ),
    );
  }

  static void showBoxDialog(BuildContext context, WidgetRef ref, String roomId, {PackingBox? box}) {
    final isEditing = box != null;
    final labelController = TextEditingController(text: box?.label);
    bool isFragile = box?.isFragile ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16, right: 16, top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Doos bewerken' : 'Nieuwe doos', 
                style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 16),
              TextField(
                controller: labelController,
                autofocus: !isEditing,
                decoration: const InputDecoration(labelText: 'Label', hintText: 'bijv. Boeken #1'),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Breekbaar'),
                subtitle: const Text('Doos bevat fragiele spullen'),
                value: isFragile,
                onChanged: (v) => setModalState(() => isFragile = v),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (labelController.text.isNotEmpty) {
                    if (isEditing) {
                      ref.read(boxProvider.notifier).update(
                        box!.copyWith(
                          label: labelController.text,
                          isFragile: isFragile,
                        )
                      );
                    } else {
                      ref.read(boxProvider.notifier).add(
                        roomId: roomId,
                        label: labelController.text,
                        isFragile: isFragile,
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
      ),
    );
  }

  static void showItemDialog(BuildContext context, WidgetRef ref, String boxId, {BoxItem? item}) {
    final isEditing = item != null;
    final nameController = TextEditingController(text: item?.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Item bewerken' : 'Item toevoegen'),
        content: TextField(
          controller: nameController,
          autofocus: !isEditing,
          decoration: const InputDecoration(labelText: 'Naam', hintText: 'bijv. Boeken'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuleren')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                if (isEditing) {
                  ref.read(boxItemProvider.notifier).update(
                    item!.copyWith(name: nameController.text)
                  );
                } else {
                  ref.read(boxItemProvider.notifier).add(
                    boxId: boxId,
                    name: nameController.text,
                  );
                }
                Navigator.pop(context);
              }
            },
            child: Text(isEditing ? 'Opslaan' : 'Toevoegen'),
          ),
        ],
      ),
    );
  }
}
