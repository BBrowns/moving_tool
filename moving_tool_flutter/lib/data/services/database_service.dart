// Database Service - Simplified for in-memory storage (can add Hive later)
import 'package:moving_tool_flutter/data/models/models.dart';

/// Simplified in-memory database service
/// Can be upgraded to Hive persistence later
class DatabaseService {
  static Project? _project;
  static final List<Task> _tasks = [];
  static final List<Room> _rooms = [];
  static final List<PackingBox> _boxes = [];
  static final List<BoxItem> _boxItems = [];
  static final List<ShoppingItem> _shopping = [];
  static final List<Expense> _expenses = [];
  static final List<JournalEntry> _journal = [];
  static final List<PlaybookNote> _notes = [];

  static Future<void> initialize() async {
    // No-op for now, can add Hive initialization later
  }

  // Project operations
  static Project? getProject() => _project;

  static Future<void> saveProject(Project project) async {
    _project = project;
  }

  // Task operations
  static List<Task> getAllTasks() => List.unmodifiable(_tasks);
  
  static Future<void> saveTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
    } else {
      _tasks.add(task);
    }
  }
  
  static Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
  }

  // Room operations
  static List<Room> getAllRooms() => List.unmodifiable(_rooms);
  
  static Future<void> saveRoom(Room room) async {
    final index = _rooms.indexWhere((r) => r.id == room.id);
    if (index >= 0) {
      _rooms[index] = room;
    } else {
      _rooms.add(room);
    }
  }
  
  static Future<void> deleteRoom(String id) async {
    _rooms.removeWhere((r) => r.id == id);
    // Also delete boxes in this room
    _boxes.removeWhere((b) => b.roomId == id);
  }

  // Box operations
  static List<PackingBox> getAllBoxes() => List.unmodifiable(_boxes);
  
  static List<PackingBox> getBoxesByRoom(String roomId) =>
      _boxes.where((b) => b.roomId == roomId).toList();
  
  static Future<void> saveBox(PackingBox box) async {
    final index = _boxes.indexWhere((b) => b.id == box.id);
    if (index >= 0) {
      _boxes[index] = box;
    } else {
      _boxes.add(box);
    }
  }
  
  static Future<void> deleteBox(String id) async {
    _boxes.removeWhere((b) => b.id == id);
    // Also delete items in this box
    _boxItems.removeWhere((i) => i.boxId == id);
  }

  // BoxItem operations
  static List<BoxItem> getAllBoxItems() => List.unmodifiable(_boxItems);
  
  static List<BoxItem> getItemsByBox(String boxId) =>
      _boxItems.where((i) => i.boxId == boxId).toList();
  
  static Future<void> saveBoxItem(BoxItem item) async {
    final index = _boxItems.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      _boxItems[index] = item;
    } else {
      _boxItems.add(item);
    }
  }
  
  static Future<void> deleteBoxItem(String id) async {
    _boxItems.removeWhere((i) => i.id == id);
  }

  // Shopping operations
  static List<ShoppingItem> getAllShoppingItems() => List.unmodifiable(_shopping);
  
  static Future<void> saveShoppingItem(ShoppingItem item) async {
    final index = _shopping.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      _shopping[index] = item;
    } else {
      _shopping.add(item);
    }
  }
  
  static Future<void> deleteShoppingItem(String id) async {
    _shopping.removeWhere((i) => i.id == id);
  }

  // Expense operations
  static List<Expense> getAllExpenses() => List.unmodifiable(_expenses);
  
  static Future<void> saveExpense(Expense expense) async {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index >= 0) {
      _expenses[index] = expense;
    } else {
      _expenses.add(expense);
    }
  }
  
  static Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
  }

  // Journal operations
  static List<JournalEntry> getAllJournalEntries() => List.unmodifiable(_journal);
  
  static Future<void> saveJournalEntry(JournalEntry entry) async {
    _journal.add(entry);
  }

  // Notes operations
  static List<PlaybookNote> getAllNotes() => List.unmodifiable(_notes);
  
  static Future<void> saveNote(PlaybookNote note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      _notes[index] = note;
    } else {
      _notes.add(note);
    }
  }
  
  static Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
  }

  // Clear all data
  static Future<void> clearAll() async {
    _project = null;
    _tasks.clear();
    _rooms.clear();
    _boxes.clear();
    _boxItems.clear();
    _shopping.clear();
    _expenses.clear();
    _journal.clear();
    _notes.clear();
  }
}
