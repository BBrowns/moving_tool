import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:moving_tool_flutter/core/models/models.dart';
import 'package:moving_tool_flutter/features/packing/domain/repositories/packing_repository.dart';
import 'package:moving_tool_flutter/features/packing/data/repositories/packing_repository_impl.dart';

const _uuid = Uuid();

// ============================================================================
// Repository Provider
// ============================================================================

final packingRepositoryProvider = Provider<PackingRepository>((ref) {
  return PackingRepositoryImpl();
});

// ============================================================================
// Packing Providers (Room, PackingBox, BoxItem)
// ============================================================================

class RoomNotifier extends Notifier<List<Room>> {
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

final roomProvider = NotifierProvider<RoomNotifier, List<Room>>(RoomNotifier.new);

class BoxNotifier extends Notifier<List<PackingBox>> {
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

final boxProvider = NotifierProvider<BoxNotifier, List<PackingBox>>(BoxNotifier.new);

class BoxItemNotifier extends Notifier<List<BoxItem>> {
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

final boxItemProvider = NotifierProvider<BoxItemNotifier, List<BoxItem>>(BoxItemNotifier.new);

// ============================================================================
// Derived Providers (Selectors)
// ============================================================================

final roomBoxesProvider = Provider.family<List<PackingBox>, String>((ref, roomId) {
  final boxes = ref.watch(boxProvider);
  return boxes.where((b) => b.roomId == roomId).toList();
});

final boxItemsProvider = Provider.family<List<BoxItem>, String>((ref, boxId) {
  final items = ref.watch(boxItemProvider);
  return items.where((i) => i.boxId == boxId).toList();
});

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

final packingStatsProvider = Provider<PackingStats>((ref) {
  final boxes = ref.watch(boxProvider);
  final items = ref.watch(boxItemProvider);

  final totalBoxes = boxes.length;
  final packedBoxes = boxes.where((b) => 
    b.status == BoxStatus.packed || b.status == BoxStatus.moved
  ).length;
  final totalItems = items.length;

  return PackingStats(
    totalBoxes: totalBoxes,
    packedBoxes: packedBoxes,
    totalItems: totalItems,
  );
});
