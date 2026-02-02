import 'package:moving_tool_flutter/data/services/database_service.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/room.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/packing_box.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/box_item.dart';
import 'package:moving_tool_flutter/features/packing/domain/repositories/packing_repository.dart';

class PackingRepositoryImpl implements PackingRepository {
  // Rooms
  @override
  Future<List<Room>> getRooms() async {
    return DatabaseService.getAllRooms();
  }

  @override
  Future<void> saveRoom(Room room) async {
    return DatabaseService.saveRoom(room);
  }

  @override
  Future<void> deleteRoom(String id) async {
    return DatabaseService.deleteRoom(id);
  }

  // Boxes
  @override
  Future<List<PackingBox>> getBoxes() async {
    return DatabaseService.getAllBoxes();
  }

  @override
  Future<void> saveBox(PackingBox box) async {
    return DatabaseService.saveBox(box);
  }

  @override
  Future<void> deleteBox(String id) async {
    return DatabaseService.deleteBox(id);
  }

  // Items
  @override
  Future<List<BoxItem>> getItems() async {
    return DatabaseService.getAllBoxItems();
  }

  @override
  Future<void> saveItem(BoxItem item) async {
    return DatabaseService.saveBoxItem(item);
  }

  @override
  Future<void> deleteItem(String id) async {
    return DatabaseService.deleteBoxItem(id);
  }
}
