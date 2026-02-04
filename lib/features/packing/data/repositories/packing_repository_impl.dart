import 'package:flutter/foundation.dart';
import 'package:moving_tool_flutter/core/error/exceptions.dart';
import 'package:moving_tool_flutter/data/services/database_service.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/box_item.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/packing_box.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/room.dart';
import 'package:moving_tool_flutter/features/packing/domain/repositories/packing_repository.dart';

class PackingRepositoryImpl implements PackingRepository {
  // Rooms
  @override
  Future<List<Room>> getRooms() async {
    try {
      return DatabaseService.getAllRooms();
    } catch (e) {
      debugPrint('Error getting rooms: $e');
      throw FetchFailure('Failed to load rooms', e);
    }
  }

  @override
  Future<void> saveRoom(Room room) async {
    try {
      await DatabaseService.saveRoom(room);
    } catch (e) {
      debugPrint('Error saving room: $e');
      throw SaveFailure('Failed to save room', e);
    }
  }

  @override
  Future<void> deleteRoom(String id) async {
    try {
      await DatabaseService.deleteRoom(id);
    } catch (e) {
      debugPrint('Error deleting room: $e');
      throw DeleteFailure('Failed to delete room', e);
    }
  }

  // Boxes
  @override
  Future<List<PackingBox>> getBoxes() async {
    try {
      return DatabaseService.getAllBoxes();
    } catch (e) {
      debugPrint('Error getting boxes: $e');
      throw FetchFailure('Failed to load boxes', e);
    }
  }

  @override
  Future<void> saveBox(PackingBox box) async {
    try {
      await DatabaseService.saveBox(box);
    } catch (e) {
      debugPrint('Error saving box: $e');
      throw SaveFailure('Failed to save box', e);
    }
  }

  @override
  Future<void> deleteBox(String id) async {
    try {
      await DatabaseService.deleteBox(id);
    } catch (e) {
      debugPrint('Error deleting box: $e');
      throw DeleteFailure('Failed to delete box', e);
    }
  }

  // Items
  @override
  Future<List<BoxItem>> getItems() async {
    try {
      return DatabaseService.getAllBoxItems();
    } catch (e) {
      debugPrint('Error getting items: $e');
      throw FetchFailure('Failed to load items', e);
    }
  }

  @override
  Future<void> saveItem(BoxItem item) async {
    try {
      await DatabaseService.saveBoxItem(item);
    } catch (e) {
      debugPrint('Error saving item: $e');
      throw SaveFailure('Failed to save item', e);
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    try {
      await DatabaseService.deleteBoxItem(id);
    } catch (e) {
      debugPrint('Error deleting item: $e');
      throw DeleteFailure('Failed to delete item', e);
    }
  }
}
