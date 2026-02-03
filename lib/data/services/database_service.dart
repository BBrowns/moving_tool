// Database Service - Hive-based persistent storage
import 'dart:io';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moving_tool_flutter/core/models/models.dart';
import 'package:moving_tool_flutter/features/expenses/domain/entities/settlement_batch.dart';
import 'package:moving_tool_flutter/features/shopping/data/models/shopping_item_model.dart';
import 'package:moving_tool_flutter/features/packing/data/models/room_model.dart';
import 'package:moving_tool_flutter/features/packing/data/models/packing_box_model.dart';
import 'package:moving_tool_flutter/features/packing/data/models/box_item_model.dart';
import 'package:moving_tool_flutter/features/projects/data/models/project_model.dart';
import 'package:moving_tool_flutter/features/tasks/data/models/task_model.dart';
import 'package:moving_tool_flutter/features/expenses/data/models/expense_model.dart';
import 'package:moving_tool_flutter/features/expenses/data/models/settlement_batch_model.dart';

/// Hive-based database service with persistent storage
class DatabaseService {
  static const String _projectsBox = 'projects';
  static const String _tasksBox = 'tasks';
  static const String _roomsBox = 'rooms';
  static const String _boxesBox = 'boxes';
  static const String _boxItemsBox = 'boxItems';
  static const String _shoppingBox = 'shopping';
  static const String _expensesBox = 'expenses';
  static const String _journalBox = 'journal';
  static const String _notesBox = 'notes';
  static const String _settingsBox = 'settings';
  static const String _settlementsBox = 'settlements';
  
  static const String _activeProjectKey = 'activeProjectId';
  


  // ... (Add Settlement Operations)
  // ============================================================================
  // Settlement operations
  // ============================================================================
  
  static List<SettlementBatch> getAllSettlementBatches() {
    final box = Hive.box<String>(_settlementsBox);
    return box.values.map((json) => _settlementBatchFromJson(json)).toList();
  }
  
  static Future<void> saveSettlementBatch(SettlementBatch batch) async {
    final box = Hive.box<String>(_settlementsBox);
    await box.put(batch.id, _settlementBatchToJson(batch));
  }
  
  static Future<void> deleteSettlementBatch(String id) async {
    final box = Hive.box<String>(_settlementsBox);
    await box.delete(id);
  }

  // ... (Add JSON helpers)
  static String _settlementBatchToJson(SettlementBatch b) {
    final model = b is SettlementBatchModel ? b : SettlementBatchModel.fromEntity(b);
    return jsonEncode(model.toJson());
  }
  
  static SettlementBatch _settlementBatchFromJson(String json) {
    return SettlementBatchModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }


  static Future<void> initialize({bool isTest = false, String? testPath}) async {
    if (isTest) {
      // In test mode, Initialize Hive with a temporary directory
      // This avoids platform channel issues (MissingPluginException)
      // and keeps tests isolated.
      final path = testPath ?? Directory.systemTemp.path;
      Hive.init(path);
    } else {
      await Hive.initFlutter();
    }
    
    // Open all boxes
    await Hive.openBox<String>(_projectsBox);
    await Hive.openBox<String>(_tasksBox);
    await Hive.openBox<String>(_roomsBox);
    await Hive.openBox<String>(_boxesBox);
    await Hive.openBox<String>(_boxItemsBox);
    await Hive.openBox<String>(_shoppingBox);
    await Hive.openBox<String>(_expensesBox);
    await Hive.openBox<String>(_journalBox);
    await Hive.openBox<String>(_notesBox);
    await Hive.openBox<String>(_settingsBox);
    await Hive.openBox<String>(_settlementsBox);
  }

  // ============================================================================
  // Project operations - Multi-project support
  // ============================================================================
  
  static List<Project> getAllProjects() {
    final box = Hive.box<String>(_projectsBox);
    return box.values.map((json) => _projectFromJson(json)).toList();
  }
  
  static Project? getProject() {
    final activeId = getActiveProjectId();
    if (activeId == null) return null;
    
    final box = Hive.box<String>(_projectsBox);
    final json = box.get(activeId);
    if (json == null) {
      // If active project doesn't exist, try to get first project
      if (box.isEmpty) return null;
      final firstJson = box.values.first;
      return _projectFromJson(firstJson);
    }
    return _projectFromJson(json);
  }
  
  static String? getActiveProjectId() {
    final settingsBox = Hive.box<String>(_settingsBox);
    return settingsBox.get(_activeProjectKey);
  }

  static Future<void> saveProject(Project project) async {
    final box = Hive.box<String>(_projectsBox);
    await box.put(project.id, _projectToJson(project));
    
    // Auto-set as active if it's the first project
    if (getActiveProjectId() == null) {
      await setActiveProject(project.id);
    }
  }
  
  static Future<void> setActiveProject(String projectId) async {
    final settingsBox = Hive.box<String>(_settingsBox);
    await settingsBox.put(_activeProjectKey, projectId);
  }
  
  static Future<void> deleteProject(String projectId) async {
    final box = Hive.box<String>(_projectsBox);
    await box.delete(projectId);
    
    // If deleting active project, clear associated data and set new active
    final activeId = getActiveProjectId();
    if (activeId == projectId) {
      // Clear all associated data for this project
      await Hive.box<String>(_tasksBox).clear();
      await Hive.box<String>(_roomsBox).clear();
      await Hive.box<String>(_boxesBox).clear();
      await Hive.box<String>(_boxItemsBox).clear();
      await Hive.box<String>(_shoppingBox).clear();
      await Hive.box<String>(_expensesBox).clear();
      await Hive.box<String>(_journalBox).clear();
      await Hive.box<String>(_notesBox).clear();
      
      // Set new active project if available
      if (box.isNotEmpty) {
        final firstProject = _projectFromJson(box.values.first);
        await setActiveProject(firstProject.id);
      } else {
        await Hive.box<String>(_settingsBox).delete(_activeProjectKey);
      }
    }
  }

  // ============================================================================
  // Task operations
  // ============================================================================
  
  static List<Task> getAllTasks() {
    final box = Hive.box<String>(_tasksBox);
    return box.values.map((json) => _taskFromJson(json)).toList();
  }
  
  static Future<void> saveTask(Task task) async {
    final box = Hive.box<String>(_tasksBox);
    await box.put(task.id, _taskToJson(task));
  }
  
  static Future<void> deleteTask(String id) async {
    final box = Hive.box<String>(_tasksBox);
    await box.delete(id);
  }

  // ============================================================================
  // Room operations
  // ============================================================================
  
  static List<Room> getAllRooms() {
    final box = Hive.box<String>(_roomsBox);
    return box.values.map((json) => _roomFromJson(json)).toList();
  }
  
  static Future<void> saveRoom(Room room) async {
    final box = Hive.box<String>(_roomsBox);
    await box.put(room.id, _roomToJson(room));
  }
  
  static Future<void> deleteRoom(String id) async {
    final box = Hive.box<String>(_roomsBox);
    await box.delete(id);
    
    // Also delete boxes in this room
    final boxesBox = Hive.box<String>(_boxesBox);
    final boxesToDelete = getAllBoxes().where((b) => b.roomId == id).map((b) => b.id).toList();
    for (final boxId in boxesToDelete) {
      await boxesBox.delete(boxId);
    }
  }

  // ============================================================================
  // Box operations
  // ============================================================================
  
  static List<PackingBox> getAllBoxes() {
    final box = Hive.box<String>(_boxesBox);
    return box.values.map((json) => _boxFromJson(json)).toList();
  }
  
  static List<PackingBox> getBoxesByRoom(String roomId) {
    return getAllBoxes().where((b) => b.roomId == roomId).toList();
  }
  
  static Future<void> saveBox(PackingBox packingBox) async {
    final box = Hive.box<String>(_boxesBox);
    await box.put(packingBox.id, _boxToJson(packingBox));
  }
  
  static Future<void> deleteBox(String id) async {
    final box = Hive.box<String>(_boxesBox);
    await box.delete(id);
    
    // Also delete items in this box
    final itemsBox = Hive.box<String>(_boxItemsBox);
    final itemsToDelete = getAllBoxItems().where((i) => i.boxId == id).map((i) => i.id).toList();
    for (final itemId in itemsToDelete) {
      await itemsBox.delete(itemId);
    }
  }

  // ============================================================================
  // BoxItem operations
  // ============================================================================
  
  static List<BoxItem> getAllBoxItems() {
    final box = Hive.box<String>(_boxItemsBox);
    return box.values.map((json) => _boxItemFromJson(json)).toList();
  }
  
  static List<BoxItem> getItemsByBox(String boxId) {
    return getAllBoxItems().where((i) => i.boxId == boxId).toList();
  }
  
  static Future<void> saveBoxItem(BoxItem item) async {
    final box = Hive.box<String>(_boxItemsBox);
    await box.put(item.id, _boxItemToJson(item));
  }
  
  static Future<void> deleteBoxItem(String id) async {
    final box = Hive.box<String>(_boxItemsBox);
    await box.delete(id);
  }

  // ============================================================================
  // Shopping operations
  // ============================================================================
  
  static List<ShoppingItem> getAllShoppingItems() {
    final box = Hive.box<String>(_shoppingBox);
    return box.values.map((json) => _shoppingItemFromJson(json)).toList();
  }
  
  static Future<void> saveShoppingItem(ShoppingItem item) async {
    final box = Hive.box<String>(_shoppingBox);
    await box.put(item.id, _shoppingItemToJson(item));
  }
  
  static Future<void> deleteShoppingItem(String id) async {
    final box = Hive.box<String>(_shoppingBox);
    await box.delete(id);
  }

  // ============================================================================
  // Expense operations
  // ============================================================================
  
  static List<Expense> getAllExpenses() {
    final box = Hive.box<String>(_expensesBox);
    return box.values.map((json) => _expenseFromJson(json)).toList();
  }
  
  static Future<void> saveExpense(Expense expense) async {
    final box = Hive.box<String>(_expensesBox);
    await box.put(expense.id, _expenseToJson(expense));
  }
  
  static Future<void> deleteExpense(String id) async {
    final box = Hive.box<String>(_expensesBox);
    await box.delete(id);
  }

  // ============================================================================
  // Journal operations
  // ============================================================================
  
  static List<JournalEntry> getAllJournalEntries() {
    final box = Hive.box<String>(_journalBox);
    return box.values.map((json) => _journalEntryFromJson(json)).toList();
  }
  
  static Future<void> saveJournalEntry(JournalEntry entry) async {
    final box = Hive.box<String>(_journalBox);
    await box.put(entry.id, _journalEntryToJson(entry));
  }

  // ============================================================================
  // Notes operations
  // ============================================================================
  
  static List<PlaybookNote> getAllNotes() {
    final box = Hive.box<String>(_notesBox);
    return box.values.map((json) => _noteFromJson(json)).toList();
  }
  
  static Future<void> saveNote(PlaybookNote note) async {
    final box = Hive.box<String>(_notesBox);
    await box.put(note.id, _noteToJson(note));
  }
  
  static Future<void> deleteNote(String id) async {
    final box = Hive.box<String>(_notesBox);
    await box.delete(id);
  }

  // ============================================================================
  // Clear all data
  // ============================================================================
  
  static Future<void> clearAll() async {
    await Hive.box<String>(_projectsBox).clear();
    await Hive.box<String>(_tasksBox).clear();
    await Hive.box<String>(_roomsBox).clear();
    await Hive.box<String>(_boxesBox).clear();
    await Hive.box<String>(_boxItemsBox).clear();
    await Hive.box<String>(_shoppingBox).clear();
    await Hive.box<String>(_expensesBox).clear();
    await Hive.box<String>(_journalBox).clear();
    await Hive.box<String>(_notesBox).clear();
    await Hive.box<String>(_settingsBox).clear();
  }

  // ============================================================================
  // JSON Serialization helpers
  // ============================================================================
  
  static String _projectToJson(Project p) {
    final model = p is ProjectModel ? p : ProjectModel.fromEntity(p);
    return jsonEncode(model.toJson());
  }
  
  static Project _projectFromJson(String json) {
    return ProjectModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  static String _taskToJson(Task t) {
    final model = t is TaskModel ? t : TaskModel.fromEntity(t);
    return jsonEncode(model.toJson());
  }
  
  static Task _taskFromJson(String json) {
    return TaskModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  static String _roomToJson(Room r) {
    final model = r is RoomModel ? r : RoomModel.fromEntity(r);
    return jsonEncode(model.toJson());
  }
  
  static Room _roomFromJson(String json) {
    return RoomModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  static String _boxToJson(PackingBox b) {
    final model = b is PackingBoxModel ? b : PackingBoxModel.fromEntity(b);
    return jsonEncode(model.toJson());
  }
  
  static PackingBox _boxFromJson(String json) {
    return PackingBoxModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  static String _boxItemToJson(BoxItem i) {
    final model = i is BoxItemModel ? i : BoxItemModel.fromEntity(i);
    return jsonEncode(model.toJson());
  }
  
  static BoxItem _boxItemFromJson(String json) {
    return BoxItemModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  static String _shoppingItemToJson(ShoppingItem i) {
    final model = i is ShoppingItemModel ? i : ShoppingItemModel.fromEntity(i);
    return jsonEncode(model.toJson());
  }
  
  static ShoppingItem _shoppingItemFromJson(String json) {
    return ShoppingItemModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  static String _expenseToJson(Expense e) {
    final model = e is ExpenseModel ? e : ExpenseModel.fromEntity(e);
    return jsonEncode(model.toJson());
  }
  
  static Expense _expenseFromJson(String json) {
    return ExpenseModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  static String _journalEntryToJson(JournalEntry e) => jsonEncode({
    'id': e.id,
    'type': e.type.index,
    'title': e.title,
    'description': e.description,
    'userId': e.userId,
    'relatedEntityId': e.relatedEntityId,
    'metadata': e.metadata,
    'timestamp': e.timestamp.toIso8601String(),
  });
  
  static JournalEntry _journalEntryFromJson(String json) {
    final m = jsonDecode(json) as Map<String, dynamic>;
    return JournalEntry(
      id: m['id'],
      type: JournalEventType.values[m['type']],
      title: m['title'],
      description: m['description'],
      userId: m['userId'],
      relatedEntityId: m['relatedEntityId'],
      metadata: m['metadata'] != null ? Map<String, dynamic>.from(m['metadata']) : null,
      timestamp: DateTime.parse(m['timestamp']),
    );
  }

  static String _noteToJson(PlaybookNote n) => jsonEncode({
    'id': n.id,
    'title': n.title,
    'content': n.content,
    'category': n.category,
    'isPinned': n.isPinned,
    'createdAt': n.createdAt.toIso8601String(),
    'updatedAt': n.updatedAt.toIso8601String(),
  });
  
  static PlaybookNote _noteFromJson(String json) {
    final m = jsonDecode(json) as Map<String, dynamic>;
    return PlaybookNote(
      id: m['id'],
      title: m['title'],
      content: m['content'],
      category: m['category'],
      isPinned: m['isPinned'] ?? false,
      createdAt: DateTime.parse(m['createdAt']),
      updatedAt: DateTime.parse(m['updatedAt']),
    );
  }

  // ============================================================================
  // Settings operations
  // ============================================================================
  
  static Future<void> saveSetting(String key, String value) async {
    final box = Hive.box<String>(_settingsBox);
    await box.put(key, value);
  }
  
  static String? getSetting(String key) {
    final box = Hive.box<String>(_settingsBox);
    return box.get(key);
  }
  
  static Future<void> deleteSetting(String key) async {
    final box = Hive.box<String>(_settingsBox);
    await box.delete(key);
  }
}

