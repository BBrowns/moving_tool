import 'package:moving_tool_flutter/core/models/item_dimensions.dart';
import 'package:moving_tool_flutter/features/ar_studio/data/repositories/room_repository.dart';
import 'package:moving_tool_flutter/features/ar_studio/domain/entities/room.dart';
import 'package:moving_tool_flutter/features/projects/presentation/providers/project_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

part 'room_providers.g.dart';

const _uuid = Uuid();

// ============================================================================
// Rooms Notifier
// ============================================================================

@riverpod
class RoomsNotifier extends _$RoomsNotifier {
  @override
  Future<List<Room>> build() async {
    final project = ref.watch(projectProvider);
    if (project == null) return [];

    final prefs = await SharedPreferences.getInstance();
    final repo = RoomRepositoryImpl(prefs);
    return repo.getRooms(project.id);
  }

  Future<void> addRoom({
    required String name,
    RoomDimensions? dimensions,
  }) async {
    final project = ref.read(projectProvider);
    if (project == null) return;

    final room = Room(
      id: _uuid.v4(),
      projectId: project.id,
      name: name,
      dimensions: dimensions,
      createdAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    final repo = RoomRepositoryImpl(prefs);
    await repo.saveRoom(room);
    ref.invalidateSelf();
  }

  Future<void> updateRoom(Room room) async {
    final prefs = await SharedPreferences.getInstance();
    final repo = RoomRepositoryImpl(prefs);
    await repo.saveRoom(room);
    ref.invalidateSelf();
  }

  Future<void> deleteRoom(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final repo = RoomRepositoryImpl(prefs);
    await repo.deleteRoom(roomId);
    ref.invalidateSelf();
  }

  Future<void> addVirtualItem({
    required String roomId,
    required String name,
    required double depthCm,
    required double widthCm,
    required double heightCm,
    String? shoppingItemId,
    String color = '#4CAF50',
  }) async {
    final item = VirtualItem(
      id: _uuid.v4(),
      roomId: roomId,
      name: name,
      dimensions: ItemDimensions(
        depthCm: depthCm,
        widthCm: widthCm,
        heightCm: heightCm,
      ),
      shoppingItemId: shoppingItemId,
      color: color,
    );

    final prefs = await SharedPreferences.getInstance();
    final repo = RoomRepositoryImpl(prefs);
    await repo.addVirtualItem(roomId, item);
    ref.invalidateSelf();
  }

  Future<void> removeVirtualItem(String roomId, String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final repo = RoomRepositoryImpl(prefs);
    await repo.removeVirtualItem(roomId, itemId);
    ref.invalidateSelf();
  }
}

// ============================================================================
// Single Room Provider
// ============================================================================

@riverpod
Future<Room?> roomById(Ref ref, String roomId) async {
  final prefs = await SharedPreferences.getInstance();
  final repo = RoomRepositoryImpl(prefs);
  return repo.getRoom(roomId);
}

// ============================================================================
// Computed Providers
// ============================================================================

/// Total rooms count
@riverpod
int roomsCount(Ref ref) {
  final roomsAsync = ref.watch(roomsProvider);
  return roomsAsync.value?.length ?? 0;
}

/// Total virtual items across all rooms
@riverpod
int totalVirtualItems(Ref ref) {
  final roomsAsync = ref.watch(roomsProvider);
  final rooms = roomsAsync.value;
  if (rooms == null) return 0;
  return rooms.fold(0, (int sum, Room room) => sum + room.virtualItems.length);
}
