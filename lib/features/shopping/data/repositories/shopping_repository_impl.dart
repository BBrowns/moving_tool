import 'package:flutter/foundation.dart';
import 'package:moving_tool_flutter/core/error/exceptions.dart';
import 'package:moving_tool_flutter/data/services/database_service.dart';
import 'package:moving_tool_flutter/features/shopping/domain/entities/shopping_item.dart';
import 'package:moving_tool_flutter/features/shopping/domain/repositories/shopping_repository.dart';

class ShoppingRepositoryImpl implements ShoppingRepository {
  @override
  Future<List<ShoppingItem>> getItems() async {
    try {
      return DatabaseService.getAllShoppingItems();
    } catch (e) {
      debugPrint('Error getting shopping items: $e');
      throw FetchFailure('Failed to load shopping items', e);
    }
  }

  @override
  Future<void> saveItem(ShoppingItem item) async {
    try {
      await DatabaseService.saveShoppingItem(item);
    } catch (e) {
      debugPrint('Error saving shopping item: $e');
      throw SaveFailure('Failed to save shopping item', e);
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    try {
      await DatabaseService.deleteShoppingItem(id);
    } catch (e) {
      debugPrint('Error deleting shopping item: $e');
      throw DeleteFailure('Failed to delete shopping item', e);
    }
  }
}
