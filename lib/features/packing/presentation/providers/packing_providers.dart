import 'package:moving_tool_flutter/core/models/models.dart';
import 'package:moving_tool_flutter/features/packing/data/repositories/packing_repository_impl.dart';
import 'package:moving_tool_flutter/features/packing/domain/repositories/packing_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'packing_providers.g.dart';

const _uuid = Uuid();

// ============================================================================
// Repository Provider
// ============================================================================

@Riverpod(keepAlive: true)
PackingRepository packingRepository(Ref ref) {
  return PackingRepositoryImpl();
}

// Generated provider is packingRepositoryProvider

// ============================================================================
// Packing Providers (Room, PackingBox, BoxItem)
// ============================================================================

@Riverpod(keepAlive: true)
class RoomNotifier extends _$RoomNotifier {
  late final PackingRepository repository;

  @override
  List<Room> build() {
    repository = ref.watch(packingRepositoryProvider);
    return [];
  }

  Future<void> load() async {
    state = await repository.getRooms();
  }

  Future<void> add({
    required String name,
    String icon = '📦',
    String color = '#6366F1',
    double? budget,
  }) async {
    final room = Room(
      id: _uuid.v4(),
      name: name,
      icon: icon,
      color: color,
      budget: budget,
      createdAt: DateTime.now(),
    );
    await repository.saveRoom(room);
    state = [...state, room];
  }

  Future<void> update(Room room) async {
    await repository.saveRoom(room);
    state = state.map((r) => r.id == room.id ? room : r).toList();
  }

  Future<void> delete(String id) async {
    await repository.deleteRoom(id);
    state = state.where((r) => r.id != id).toList();
  }
}

@Riverpod(keepAlive: true)
class BoxNotifier extends _$BoxNotifier {
  late final PackingRepository repository;

  @override
  List<PackingBox> build() {
    repository = ref.watch(packingRepositoryProvider);
    return [];
  }

  Future<void> load() async {
    state = await repository.getBoxes();
  }

  Future<void> add({
    required String roomId,
    required String label,
    bool isFragile = false,
  }) async {
    final box = PackingBox(
      id: _uuid.v4(),
      roomId: roomId,
      label: label,
      isFragile: isFragile,
      createdAt: DateTime.now(),
    );
    await repository.saveBox(box);
    state = [...state, box];
  }

  Future<void> update(PackingBox box) async {
    await repository.saveBox(box);
    state = state.map((b) => b.id == box.id ? box : b).toList();
  }

  Future<void> delete(String id) async {
    await repository.deleteBox(id);
    state = state.where((b) => b.id != id).toList();
  }

  Future<void> toggleBoxPacked(String id) async {
    final box = state.firstWhere((b) => b.id == id);
    final newStatus = box.status == BoxStatus.packed
        ? BoxStatus.packing
        : BoxStatus.packed;

    final updated = box.copyWith(status: newStatus);
    await update(updated);
  }
}

@Riverpod(keepAlive: true)
class BoxItemNotifier extends _$BoxItemNotifier {
  late final PackingRepository repository;

  @override
  List<BoxItem> build() {
    repository = ref.watch(packingRepositoryProvider);
    return [];
  }

  Future<void> load() async {
    state = await repository.getItems();
  }

  Future<void> add({
    required String boxId,
    required String name,
    int quantity = 1,
    double? estimatedValue,
  }) async {
    final item = BoxItem(
      id: _uuid.v4(),
      boxId: boxId,
      name: name,
      quantity: quantity,
      estimatedValue: estimatedValue,
      createdAt: DateTime.now(),
    );
    await repository.saveItem(item);
    state = [...state, item];
  }

  Future<void> update(BoxItem item) async {
    await repository.saveItem(item);
    state = state.map((i) => i.id == item.id ? item : i).toList();
  }

  Future<void> delete(String id) async {
    await repository.deleteItem(id);
    state = state.where((i) => i.id != id).toList();
  }

  Future<void> togglePacked(String id) async {
    final item = state.firstWhere((i) => i.id == id);
    final updated = item.copyWith(isPacked: !item.isPacked);
    await update(updated);
  }
}

// ============================================================================
// Derived Providers (Selectors)
// ============================================================================

@Riverpod(keepAlive: true)
List<PackingBox> roomBoxes(Ref ref, String roomId) {
  final boxes = ref.watch(boxProvider);
  return boxes.where((b) => b.roomId == roomId).toList();
}

// Alias
// Alias
// final roomBoxesProvider = roomBoxesProvider;
// Generated: roomBoxesProvider.
// But wait, generated provider for family is usually `roomBoxesProvider`.
// So explicit alias might be redundant or error-prone (circular).
// I should CHECK usage. If I define `roomBoxesProvider` manually and generated one has same name -> collision.
// I will rename the function to avoid collision, or use the generated name.
// Existing usage: `ref.watch(roomBoxesProvider(roomId))` or `ref.watch(roomBoxesProvider(roomId))`.
// Manual family: `roomBoxesProvider(roomId)`.
// Generated family: `roomBoxesProvider(roomId)`.
// So if I name the function `roomBoxes`, the provider is `roomBoxesProvider`.
// I MUST NOT define a manual variable with the same name.
// So I will just use the generated provider.

@Riverpod(keepAlive: true)
List<BoxItem> itemsInBox(Ref ref, String boxId) {
  final items = ref.watch(boxItemProvider);
  return items.where((i) => i.boxId == boxId).toList();
}

// Alias for old name `boxItemsProvider`
final ItemsInBoxFamily boxItemsProvider = itemsInBoxProvider;

class PackingStats {
  final int totalBoxes;
  final int packedBoxes;
  final int totalItems;

  PackingStats({
    required this.totalBoxes,
    required this.packedBoxes,
    required this.totalItems,
  });
}

@Riverpod(keepAlive: true)
PackingStats packingStats(Ref ref) {
  final boxes = ref.watch(boxProvider);
  final items = ref.watch(boxItemProvider);

  final totalBoxes = boxes.length;
  final packedBoxes = boxes
      .where((b) => b.status == BoxStatus.packed || b.status == BoxStatus.moved)
      .length;
  final totalItems = items.length;

  return PackingStats(
    totalBoxes: totalBoxes,
    packedBoxes: packedBoxes,
    totalItems: totalItems,
  );
}

// Generated is `packingStatsProvider`.
