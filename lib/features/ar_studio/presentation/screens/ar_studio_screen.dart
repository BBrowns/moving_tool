import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/features/ar_studio/domain/entities/room.dart';
import 'package:moving_tool_flutter/features/ar_studio/presentation/providers/room_providers.dart';
import 'package:go_router/go_router.dart';

/// AR Studio main screen for managing rooms and virtual furniture.
class ARStudioScreen extends ConsumerStatefulWidget {
  const ARStudioScreen({super.key});

  @override
  ConsumerState<ARStudioScreen> createState() => _ARStudioScreenState();
}

class _ARStudioScreenState extends ConsumerState<ARStudioScreen> {
  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsProvider);
    final roomsCount = ref.watch(roomsCountProvider);
    final itemsCount = ref.watch(totalVirtualItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Studio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddRoomDialog(context),
            tooltip: 'Kamer toevoegen',
          ),
        ],
      ),
      body: roomsAsync.when(
        data: (rooms) {
          if (rooms.isEmpty) {
            return _EmptyState(onAdd: () => _showAddRoomDialog(context));
          }

          return CustomScrollView(
            slivers: [
              // Summary Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _SummaryItem(
                            label: 'Kamers',
                            value: '$roomsCount',
                            icon: Icons.meeting_room_rounded,
                            color: AppTheme.primary,
                          ),
                          _SummaryItem(
                            label: 'Meubels',
                            value: '$itemsCount',
                            icon: Icons.chair_rounded,
                            color: AppTheme.success,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                ),
              ),

              // Rooms Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _RoomCard(
                              room: rooms[index],
                              onTap: () =>
                                  _showRoomDetail(context, rooms[index]),
                              onDelete: () =>
                                  _confirmDelete(context, rooms[index]),
                            )
                            .animate(delay: (index * 50).ms)
                            .fadeIn()
                            .slideY(begin: 0.1),
                    childCount: rooms.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Fout: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRoomDialog(context),
        icon: const Icon(Icons.add_home_rounded),
        label: const Text('Kamer scannen'),
      ),
    );
  }

  void _showAddRoomDialog(BuildContext context) {
    final nameController = TextEditingController();
    final lengthController = TextEditingController();
    final widthController = TextEditingController();
    final heightController = TextEditingController(text: '250');

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nieuwe Kamer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Naam',
                  hintText: 'bijv. Woonkamer, Slaapkamer',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              const Text(
                'Afmetingen (optioneel)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: lengthController,
                      decoration: const InputDecoration(
                        labelText: 'Lengte',
                        suffixText: 'cm',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: widthController,
                      decoration: const InputDecoration(
                        labelText: 'Breedte',
                        suffixText: 'cm',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: heightController,
                decoration: const InputDecoration(
                  labelText: 'Hoogte',
                  suffixText: 'cm',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuleer'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isEmpty) return;

              RoomDimensions? dimensions;
              final length = double.tryParse(lengthController.text);
              final width = double.tryParse(widthController.text);
              final height = double.tryParse(heightController.text);

              if (length != null && width != null && height != null) {
                dimensions = RoomDimensions(
                  lengthCm: length,
                  widthCm: width,
                  heightCm: height,
                );
              }

              ref
                  .read(roomsProvider.notifier)
                  .addRoom(name: nameController.text, dimensions: dimensions);
              Navigator.pop(context);
            },
            child: const Text('Toevoegen'),
          ),
        ],
      ),
    );
  }

  void _showRoomDetail(BuildContext context, Room room) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) =>
            _RoomDetailSheet(room: room, scrollController: scrollController),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Room room) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kamer verwijderen?'),
        content: Text(
          'Weet je zeker dat je "${room.name}" wilt verwijderen? '
          'Dit verwijdert ook ${room.virtualItems.length} meubels.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuleer'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              ref.read(roomsProvider.notifier).deleteRoom(room.id);
              Navigator.pop(context);
            },
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Empty State
// ============================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.view_in_ar_rounded,
              size: 80,
              color: context.colors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'AR Studio',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan je kamers en plaats virtuele meubels\nom te zien hoe alles past.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_home_rounded),
              label: const Text('Eerste kamer toevoegen'),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
      ),
    );
  }
}

// ============================================================================
// Summary Item
// ============================================================================

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Room Card
// ============================================================================

class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.room,
    required this.onTap,
    required this.onDelete,
  });

  final Room room;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colors.primaryContainer,
                    context.colors.primary.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.meeting_room_rounded,
                  size: 40,
                  color: context.colors.primary,
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (room.dimensions != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        room.dimensions!.toString(),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.chair_rounded,
                          size: 16,
                          color: context.colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${room.virtualItems.length} meubels',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          onPressed: onDelete,
                          iconSize: 18,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Room Detail Sheet
// ============================================================================

class _RoomDetailSheet extends ConsumerWidget {
  const _RoomDetailSheet({required this.room, required this.scrollController});

  final Room room;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (room.dimensions != null)
                        Text(
                          '${room.dimensions!.floorAreaM2.toStringAsFixed(1)} m² • '
                          '${room.dimensions!.volumeM3.toStringAsFixed(1)} m³',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        // Navigate to AR Camera
                        context.go('/ar-studio/camera?mode=furniturePlacement');
                      },
                      icon: const Icon(Icons.view_in_ar_rounded),
                      tooltip: 'Bekijk in AR',
                      style: IconButton.styleFrom(
                        backgroundColor: context.colors.primaryContainer,
                        foregroundColor: context.colors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () => _showAddFurnitureDialog(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('Meubel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          // Virtual Items List
          Expanded(
            child: room.virtualItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chair_outlined,
                          size: 48,
                          color: context.colors.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nog geen meubels',
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: room.virtualItems.length,
                    itemBuilder: (context, index) {
                      final item = room.virtualItems[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(
                              int.parse(item.color.replaceFirst('#', '0xFF')),
                            ).withValues(alpha: 0.2),
                            child: Icon(
                              Icons.chair_rounded,
                              color: Color(
                                int.parse(item.color.replaceFirst('#', '0xFF')),
                              ),
                            ),
                          ),
                          title: Text(item.name),
                          subtitle: Text(item.dimensions.toString()),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              ref
                                  .read(roomsProvider.notifier)
                                  .removeVirtualItem(room.id, item.id);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ).animate(delay: (index * 50).ms).fadeIn();
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddFurnitureDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final lengthController = TextEditingController();
    final widthController = TextEditingController();
    final heightController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Meubel Toevoegen'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Naam',
                  hintText: 'bijv. Bank, Tafel, Kast',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: lengthController,
                      decoration: const InputDecoration(
                        labelText: 'L',
                        suffixText: 'cm',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: widthController,
                      decoration: const InputDecoration(
                        labelText: 'B',
                        suffixText: 'cm',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: heightController,
                      decoration: const InputDecoration(
                        labelText: 'H',
                        suffixText: 'cm',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuleer'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text;
              final length = double.tryParse(lengthController.text);
              final width = double.tryParse(widthController.text);
              final height = double.tryParse(heightController.text);

              if (name.isEmpty ||
                  length == null ||
                  width == null ||
                  height == null) {
                return;
              }

              ref
                  .read(roomsProvider.notifier)
                  .addVirtualItem(
                    roomId: room.id,
                    name: name,
                    depthCm: length,
                    widthCm: width,
                    heightCm: height,
                  );
              Navigator.pop(dialogContext);
              Navigator.pop(context); // Close bottom sheet
            },
            child: const Text('Toevoegen'),
          ),
        ],
      ),
    );
  }
}
