import 'package:moving_tool_flutter/features/packing/domain/entities/box_item.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/packing_box.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/room.dart';

abstract class PackingRepository {
  // Rooms
  Future<List<Room>> getRooms();
  Future<void> saveRoom(Room room);
  Future<void> deleteRoom(String id);

  // Boxes
  Future<List<PackingBox>> getBoxes();
  Future<void> saveBox(PackingBox box);
  Future<void> deleteBox(String id);

  // Items
  Future<List<BoxItem>> getItems();
  Future<void> saveItem(BoxItem item);
  Future<void> deleteItem(String id);
}
