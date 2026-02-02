import 'package:moving_tool_flutter/data/services/database_service.dart';
import 'package:moving_tool_flutter/features/shopping/domain/entities/shopping_item.dart';
import 'package:moving_tool_flutter/features/shopping/domain/repositories/shopping_repository.dart';

class ShoppingRepositoryImpl implements ShoppingRepository {
  @override
  Future<List<ShoppingItem>> getItems() async {
    return DatabaseService.getAllShoppingItems();
  }

  @override
  Future<void> saveItem(ShoppingItem item) async {
    return DatabaseService.saveShoppingItem(item);
  }

  @override
  Future<void> deleteItem(String id) async {
    return DatabaseService.deleteShoppingItem(id);
  }
}
