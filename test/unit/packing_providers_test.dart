import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/box_item.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/packing_box.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/room.dart';
import 'package:moving_tool_flutter/features/packing/domain/repositories/packing_repository.dart';
import 'package:moving_tool_flutter/features/packing/presentation/providers/packing_providers.dart';

// Manual Mock for PackingRepository to avoid build_runner dependency for this snippet
class MockPackingRepository extends Mock implements PackingRepository {
  final List<BoxItem> _items = [];

  @override
  Future<void> saveItem(BoxItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      _items[index] = item;
    } else {
      _items.add(item);
    }
  }

  @override
  Future<List<BoxItem>> getItems() async => _items;
  
  @override
  Future<void> deleteItem(String id) async {
    _items.removeWhere((i) => i.id == id);
  }

  // Missing implementations
  @override
  Future<void> deleteBox(String id) async {}

  @override
  Future<void> deleteRoom(String id) async {}
  
  @override
  Future<List<PackingBox>> getBoxes() async => [];
  
  @override
  Future<List<Room>> getRooms() async => [];
  
  @override
  Future<void> saveBox(PackingBox box) async {}
  
  @override
  Future<void> saveRoom(Room room) async {}
}

void main() {
  late MockPackingRepository mockRepository;

  setUp(() {
    mockRepository = MockPackingRepository();
  });

  group('Packing Providers Unit Tests', () {
    test('BoxItemNotifier adds item and updates state', () async {
      final container = ProviderContainer(
        overrides: [
          packingRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(boxItemProvider.notifier);

      // 1. Initial State should be empty (or whatever build returns)
      expect(container.read(boxItemProvider), isEmpty);

      // 2. Add Item
      await notifier.add(boxId: 'box-123', name: 'Boeken', quantity: 5, estimatedValue: 50.0);

      // 3. Verify State Update
      final items = container.read(boxItemProvider);
      expect(items, hasLength(1));
      expect(items.first.name, 'Boeken');
      expect(items.first.boxId, 'box-123');
      expect(items.first.quantity, 5);

      // 4. Verify Repository Interaction (Mock logic check)
      final repoItems = await mockRepository.getItems();
      expect(repoItems, hasLength(1));
      expect(repoItems.first.name, 'Boeken');
    });

    test('BoxItemNotifier delete removes item from state', () async {
      final container = ProviderContainer(
        overrides: [
          packingRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(boxItemProvider.notifier);

      // Add item first
      await notifier.add(boxId: 'box-1', name: 'Item 1');
      final addedItem = container.read(boxItemProvider).first;

      // Delete
      await notifier.delete(addedItem.id);

      // Verify
      expect(container.read(boxItemProvider), isEmpty);
      expect(await mockRepository.getItems(), isEmpty);
    });

    test('BoxItemNotifier togglePacked updates item status', () async {
       final container = ProviderContainer(
        overrides: [
          packingRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(boxItemProvider.notifier);
      await notifier.add(boxId: 'box-1', name: 'Item 1');
      var item = container.read(boxItemProvider).first;
      expect(item.isPacked, false);

      // Toggle
      await notifier.togglePacked(item.id);
      
      item = container.read(boxItemProvider).first;
      expect(item.isPacked, true);
    });
  });
}
