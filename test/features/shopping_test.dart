import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moving_tool_flutter/core/models/models.dart';
import 'package:moving_tool_flutter/data/providers/providers.dart';
// import 'package:mocktail/mocktail.dart'; // Removed
import 'package:moving_tool_flutter/features/shopping/domain/repositories/shopping_repository.dart';
import 'package:moving_tool_flutter/features/shopping/presentation/providers/shopping_providers.dart';
import 'package:moving_tool_flutter/features/shopping/shopping_screen.dart';

class MockShoppingRepository implements ShoppingRepository {
  MockShoppingRepository([List<ShoppingItem>? initialItems]) {
    if (initialItems != null) _items = initialItems;
  }
  List<ShoppingItem> _items = [];

  @override
  Future<List<ShoppingItem>> getItems() async => _items;

  @override
  Future<void> saveItem(ShoppingItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      _items[index] = item;
    } else {
      _items.add(item);
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    _items.removeWhere((i) => i.id == id);
  }
}

class TestShoppingNotifier extends ShoppingNotifier {
  TestShoppingNotifier(this._initialItems);
  final List<ShoppingItem> _initialItems;

  @override
  List<ShoppingItem> build() {
    repository = ref.watch(shoppingRepositoryProvider);
    return _initialItems;
  }
}

void main() {
  group('ShoppingScreen', () {
    testWidgets('Mobile: shows List View', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(480, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final item = ShoppingItem(
        id: '1',
        projectId: 'test-project',
        name: 'New Sofa',
        priority: ShoppingPriority.high,
        status: ShoppingStatus.needed,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            shoppingRepositoryProvider.overrideWithValue(
              MockShoppingRepository([item]),
            ),
            shoppingProvider.overrideWith(() => TestShoppingNotifier([item])),
          ],
          child: const MaterialApp(home: ShoppingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('New Sofa'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Desktop: shows Kanban View', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final item = ShoppingItem(
        id: '1',
        projectId: 'test-project',
        name: 'Curtains',
        priority: ShoppingPriority.medium,
        status: ShoppingStatus.needed,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            shoppingRepositoryProvider.overrideWithValue(
              MockShoppingRepository([item]),
            ),
            shoppingProvider.overrideWith(() => TestShoppingNotifier([item])),
          ],
          child: const MaterialApp(home: ShoppingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Column Headers exist
      expect(find.text('Nodig'), findsOneWidget);
      expect(find.text('Zoeken'), findsOneWidget);
      expect(find.text('Gevonden'), findsOneWidget);
      expect(find.text('Gekocht'), findsOneWidget);

      // Verify Item exists
      expect(find.text('Curtains'), findsOneWidget);
    });

    testWidgets('Add Item Dialog works', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(480, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            shoppingRepositoryProvider.overrideWithValue(
              MockShoppingRepository(),
            ),
            shoppingProvider.overrideWith(() => TestShoppingNotifier([])),
          ],
          child: const MaterialApp(home: ShoppingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Nieuw item'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Table');
      await tester.tap(find.text('Toevoegen'));
      await tester.pumpAndSettle();

      expect(find.text('Table'), findsOneWidget);
    });
  });
}
