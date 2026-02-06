import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moving_tool_flutter/features/ar_studio/domain/entities/room.dart';

/// Repository interface for Room persistence.
abstract class RoomRepository {
  Future<List<Room>> getRooms(String projectId);
  Future<Room?> getRoom(String roomId);
  Future<void> saveRoom(Room room);
  Future<void> deleteRoom(String roomId);
  Future<void> addVirtualItem(String roomId, VirtualItem item);
  Future<void> removeVirtualItem(String roomId, String itemId);
}

/// SharedPreferences implementation of RoomRepository.
class RoomRepositoryImpl implements RoomRepository {
  RoomRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'rooms';

  @override
  Future<List<Room>> getRooms(String projectId) async {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null) return [];

    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => Room.fromJson(e as Map<String, dynamic>))
        .where((r) => r.projectId == projectId)
        .toList();
  }

  @override
  Future<Room?> getRoom(String roomId) async {
    final rooms = await _getAllRooms();
    try {
      return rooms.firstWhere((r) => r.id == roomId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveRoom(Room room) async {
    final rooms = await _getAllRooms();
    final index = rooms.indexWhere((r) => r.id == room.id);

    if (index >= 0) {
      rooms[index] = room;
    } else {
      rooms.add(room);
    }

    await _saveAll(rooms);
  }

  @override
  Future<void> deleteRoom(String roomId) async {
    final rooms = await _getAllRooms();
    rooms.removeWhere((r) => r.id == roomId);
    await _saveAll(rooms);
  }

  @override
  Future<void> addVirtualItem(String roomId, VirtualItem item) async {
    final room = await getRoom(roomId);
    if (room == null) return;

    final updatedRoom = room.copyWith(
      virtualItems: [...room.virtualItems, item],
    );
    await saveRoom(updatedRoom);
  }

  @override
  Future<void> removeVirtualItem(String roomId, String itemId) async {
    final room = await getRoom(roomId);
    if (room == null) return;

    final updatedRoom = room.copyWith(
      virtualItems: room.virtualItems.where((i) => i.id != itemId).toList(),
    );
    await saveRoom(updatedRoom);
  }

  Future<List<Room>> _getAllRooms() async {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null) return [];

    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list.map((e) => Room.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _saveAll(List<Room> rooms) async {
    final jsonStr = jsonEncode(rooms.map((r) => r.toJson()).toList());
    await _prefs.setString(_key, jsonStr);
  }
}
