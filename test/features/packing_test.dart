// Packing Screen Tests
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/box_item.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/packing_box.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/room.dart';
import 'package:moving_tool_flutter/features/packing/domain/repositories/packing_repository.dart';
import 'package:moving_tool_flutter/features/packing/packing_screen.dart';
import 'package:moving_tool_flutter/features/packing/presentation/providers/packing_providers.dart';

// Mock Repository
class MockPackingRepository implements PackingRepository {

  MockPackingRepository({List<Room>? rooms, List<PackingBox>? boxes}) {
    if (rooms != null) _rooms = rooms;
    if (boxes != null) _boxes = boxes;
  }
  List<Room> _rooms = [];
  List<PackingBox> _boxes = [];
  final List<BoxItem> _items = [];

  @override
  Future<void> deleteBox(String id) async {
    _boxes.removeWhere((b) => b.id == id);
  }

  @override
  Future<void> deleteItem(String id) async {
    _items.removeWhere((i) => i.id == id);
  }

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
  Future<void> saveRoom(Room room) async {
    final index = _rooms.indexWhere((r) => r.id == room.id);
    if (index >= 0) {
      _rooms[index] = room;
    } else {
      _rooms.add(room);
    }
  }

  @override
  Future<void> deleteRoom(String id) async {
    _rooms.removeWhere((r) => r.id == id);
  }

  @override
  Future<List<PackingBox>> getBoxes() async => _boxes;

  @override
  Future<List<BoxItem>> getItems() async => _items;

  @override
  Future<List<Room>> getRooms() async => _rooms;

  @override
  Future<void> saveBox(PackingBox box) async {
    final index = _boxes.indexWhere((b) => b.id == box.id);
    if (index >= 0) {
      _boxes[index] = box;
    } else {
      _boxes.add(box);
    }
  }
}

// Test Notifiers
class TestRoomNotifier extends RoomNotifier {
  TestRoomNotifier(this._initial);
  final List<Room> _initial;
  @override
  List<Room> build() {
    repository = ref.watch(packingRepositoryProvider);
    return _initial;
  }
}

class TestBoxNotifier extends BoxNotifier {
  TestBoxNotifier(this._initial);
  final List<PackingBox> _initial;
  @override
  List<PackingBox> build() {
    repository = ref.watch(packingRepositoryProvider);
    return _initial;
  }
}

// Mock room for testing
Room createMockRoom({
  String id = 'room-1',
  String name = 'Woonkamer',
  String icon = '🛋️',
}) {
  return Room(
    id: id,
    name: name,
    icon: icon,
    color: '#6366F1',
    createdAt: DateTime.now(),
  );
}

void main() {
  group('PackingScreen', () {
    testWidgets('shows empty state when no rooms exist', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: PackingScreen())),
      );

      // Should show empty state
      expect(find.byIcon(Icons.house_rounded), findsOneWidget);
      expect(find.text('Nog geen kamers'), findsOneWidget);
      expect(
        find.text('Voeg kamers toe om te beginnen met inpakken'),
        findsOneWidget,
      );
    });

    testWidgets('shows app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: PackingScreen())),
      );

      expect(find.text('Inpakken'), findsOneWidget);
    });

    testWidgets('shows FAB to add room', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: PackingScreen())),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Kamer'), findsOneWidget);
    });

    testWidgets('shows rooms when they exist', (WidgetTester tester) async {
      final mockRoom = createMockRoom();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            packingRepositoryProvider.overrideWithValue(
              MockPackingRepository(rooms: [mockRoom]),
            ),
            roomProvider.overrideWith(() => TestRoomNotifier([mockRoom])),
          ],
          child: const MaterialApp(home: PackingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Woonkamer'), findsOneWidget);
      expect(find.byIcon(Icons.chair_rounded), findsOneWidget);
    });

    testWidgets('shows add room button in empty state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: PackingScreen())),
      );

      expect(find.text('Eerste kamer toevoegen'), findsOneWidget);
    });

    testWidgets('opens add room bottom sheet when FAB tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: PackingScreen())),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Nieuwe kamer'), findsOneWidget);
      expect(find.text('Naam'), findsOneWidget);
    });

    testWidgets('shows box count and items in room card', (
      WidgetTester tester,
    ) async {
      final mockRoom = createMockRoom();
      final mockBox = PackingBox(
        id: 'box-1',
        roomId: mockRoom.id,
        label: 'Test Box',
        isFragile: false,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            packingRepositoryProvider.overrideWithValue(
              MockPackingRepository(rooms: [mockRoom], boxes: [mockBox]),
            ),
            roomProvider.overrideWith(() => TestRoomNotifier([mockRoom])),
            boxProvider.overrideWith(() => TestBoxNotifier([mockBox])),
          ],
          child: const MaterialApp(home: PackingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Check for combined stats text (Exact match to differentiate from Chip)
      expect(find.text('1 dozen • 0 items'), findsOneWidget);

      // Check for progress bar section
      expect(find.text('Ingepakt'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('Add Box Dialog with Fragile switch works', (
      WidgetTester tester,
    ) async {
      final mockRoom = createMockRoom();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            packingRepositoryProvider.overrideWithValue(
              MockPackingRepository(rooms: [mockRoom]),
            ),
            roomProvider.overrideWith(() => TestRoomNotifier([mockRoom])),
            boxProvider.overrideWith(() => TestBoxNotifier([])),
          ],
          child: const MaterialApp(home: PackingScreen()),
        ),
      );

      // Find 'Add Box' icon button on the room card
      await tester.tap(find.byIcon(Icons.add_box_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Nieuwe doos'), findsOneWidget);

      // Enter Label
      await tester.enterText(find.byType(TextField).first, 'Fragile Box');

      // Toggle Fragile Switch
      // Find switch by name or type
      expect(find.text('Breekbaar'), findsOneWidget);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('Toevoegen'));
      await tester.pumpAndSettle();

      expect(find.text('Nieuwe doos'), findsNothing);
    });
  });
}
