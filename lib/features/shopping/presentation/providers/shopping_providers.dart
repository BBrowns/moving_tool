import 'package:moving_tool_flutter/core/models/models.dart';
import 'package:moving_tool_flutter/features/shopping/data/repositories/shopping_repository_impl.dart';
import 'package:moving_tool_flutter/features/shopping/domain/repositories/shopping_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'shopping_providers.g.dart';

const _uuid = Uuid();

// ============================================================================
// Repository Provider
// ============================================================================

@Riverpod(keepAlive: true)
ShoppingRepository shoppingRepository(Ref ref) {
  return ShoppingRepositoryImpl();
}

// Generated provider: shoppingRepositoryProvider

// ============================================================================
// Shopping Provider
// ============================================================================

@Riverpod(keepAlive: true)
class ShoppingNotifier extends _$ShoppingNotifier {
  late final ShoppingRepository repository;

  @override
  List<ShoppingItem> build() {
    repository = ref.watch(shoppingRepositoryProvider);
    return [];
  }

  Future<void> load() async {
    state = await repository.getItems(); // Update usage
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
    await repository.saveItem(item); // Update usage
    state = [...state, item];
  }

  Future<void> update(ShoppingItem item) async {
    await repository.saveItem(item); // Update usage
    state = state.map((i) => i.id == item.id ? item : i).toList();
  }

  Future<void> updateStatus(String id, ShoppingStatus status) async {
    final item = state.firstWhere((i) => i.id == id);
    final updated = item.copyWith(status: status);
    await update(updated);
  }

  Future<void> delete(String id) async {
    await repository.deleteItem(id); // Update usage
    state = state.where((i) => i.id != id).toList();
  }
}
