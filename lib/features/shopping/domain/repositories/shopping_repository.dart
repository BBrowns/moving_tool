import 'package:moving_tool_flutter/features/shopping/domain/entities/shopping_item.dart';

abstract class ShoppingRepository {
  Future<List<ShoppingItem>> getItems();
  Future<void> saveItem(ShoppingItem item);
  Future<void> deleteItem(String id);
}
