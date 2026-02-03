import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:moving_tool_flutter/core/models/models.dart';
import 'package:moving_tool_flutter/features/shopping/domain/repositories/shopping_repository.dart';
import 'package:moving_tool_flutter/features/shopping/data/repositories/shopping_repository_impl.dart';

const _uuid = Uuid();

// ============================================================================
// Repository Provider
// ============================================================================

final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  return ShoppingRepositoryImpl();
});

// ============================================================================
// Shopping Provider
// ============================================================================

class ShoppingNotifier extends Notifier<List<ShoppingItem>> {
  late final ShoppingRepository repository;

  @override
  List<ShoppingItem> build() {
    repository = ref.watch(shoppingRepositoryProvider);
    return [];
  }

  Future<void> load() async {
    state = await repository.getItems();
  }

  Future<void> add({
    required String name,
    String? roomId,
    ShoppingPriority priority = ShoppingPriority.medium,
    double? budgetMin,
    double? budgetMax,
    String? marktplaatsQuery,
    bool isMarktplaatsTracked = false,
    double? targetPrice,
  }) async {
    final item = ShoppingItem(
      id: _uuid.v4(),
      name: name,
      roomId: roomId,
      priority: priority,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      marktplaatsQuery: marktplaatsQuery,
      isMarktplaatsTracked: isMarktplaatsTracked,
      targetPrice: targetPrice,
      createdAt: DateTime.now(),
    );
    await repository.saveItem(item);
    state = [...state, item];
  }

  Future<void> update(ShoppingItem item) async {
    await repository.saveItem(item);
    state = state.map((i) => i.id == item.id ? item : i).toList();
  }

  Future<void> updateStatus(String id, ShoppingStatus status) async {
    final item = state.firstWhere((i) => i.id == id);
    final updated = item.copyWith(status: status);
    await update(updated);
  }

  Future<void> delete(String id) async {
    await repository.deleteItem(id);
    state = state.where((i) => i.id != id).toList();
  }
}

final shoppingProvider = NotifierProvider<ShoppingNotifier, List<ShoppingItem>>(ShoppingNotifier.new);
