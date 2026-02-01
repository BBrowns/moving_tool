// Packing Screen - Room and Box management
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moving_tool_flutter/data/providers/providers.dart';
import 'package:moving_tool_flutter/data/models/models.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';

class PackingScreen extends ConsumerWidget {
  const PackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(roomProvider);
    final boxes = ref.watch(boxProvider);
    final items = ref.watch(boxItemProvider);

    // Stats
    final totalBoxes = boxes.length;
    final packedBoxes = boxes.where((b) => 
      b.status == BoxStatus.packed || b.status == BoxStatus.moved
    ).length;
    final totalItems = items.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inpakken'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              avatar: const Icon(Icons.inventory_2, size: 16),
              label: Text('$packedBoxes/$totalBoxes dozen • $totalItems items'),
            ),
          ),
        ],
      ),
      body: rooms.isEmpty
          ? _buildEmptyState(context, ref)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                final roomBoxes = boxes.where((b) => b.roomId == room.id).toList();
                
                return _RoomCard(
                  room: room,
                  boxes: roomBoxes,
                  items: items,
                  onAddBox: () => _showAddBoxDialog(context, ref, room.id),
                  onDeleteRoom: () => ref.read(roomProvider.notifier).delete(room.id),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRoomDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Kamer'),
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
            onPressed: () => _showAddRoomDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Eerste kamer toevoegen'),
          ),
        ],
      ),
    );
  }

  void _showAddRoomDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String selectedIcon = '📦';

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
              Text('Nieuwe kamer', style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                autofocus: true,
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
                    ref.read(roomProvider.notifier).add(
                      name: nameController.text,
                      icon: selectedIcon,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Toevoegen'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddBoxDialog(BuildContext context, WidgetRef ref, String roomId) {
    final labelController = TextEditingController();
    bool isFragile = false;

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
              Text('Nieuwe doos', style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: labelController,
                autofocus: true,
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
                    ref.read(boxProvider.notifier).add(
                      roomId: roomId,
                      label: labelController.text,
                      isFragile: isFragile,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Toevoegen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final Room room;
  final List<PackingBox> boxes;
  final List<BoxItem> items;
  final VoidCallback onAddBox;
  final VoidCallback onDeleteRoom;

  const _RoomCard({
    required this.room,
    required this.boxes,
    required this.items,
    required this.onAddBox,
    required this.onDeleteRoom,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Text(room.icon, style: const TextStyle(fontSize: 28)),
        title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${boxes.length} dozen'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.add_box), onPressed: onAddBox, tooltip: 'Doos toevoegen'),
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDeleteRoom),
          ],
        ),
        children: boxes.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Nog geen dozen', style: TextStyle(color: context.colors.onSurfaceVariant)),
                ),
              ]
            : boxes.map((box) {
                final boxItems = items.where((i) => i.boxId == box.id).toList();
                return ListTile(
                  leading: Text(box.status.icon, style: const TextStyle(fontSize: 20)),
                  title: Text(box.label),
                  subtitle: Text('${boxItems.length} items'),
                  trailing: box.isFragile ? const Icon(Icons.warning_amber, color: Colors.orange) : null,
                );
              }).toList(),
      ),
    );
  }
}
