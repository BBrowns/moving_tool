// Riverpod Providers - State management for the app
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:moving_tool_flutter/data/models/models.dart';
import 'package:moving_tool_flutter/data/services/database_service.dart';

const _uuid = Uuid();

// ============================================================================
// Project Provider
// ============================================================================

class ProjectNotifier extends StateNotifier<Project?> {
  ProjectNotifier() : super(null);

  void load() {
    state = DatabaseService.getProject();
  }

  Future<void> save(Project project) async {
    await DatabaseService.saveProject(project);
    state = project;
  }

  Future<void> addUser(String name, String color) async {
    if (state == null) return;
    final user = User(id: _uuid.v4(), name: name, color: color);
    final updated = state!.copyWith(users: [...state!.users, user]);
    await save(updated);
  }
}

final projectProvider = StateNotifierProvider<ProjectNotifier, Project?>((ref) {
  return ProjectNotifier();
});

// ============================================================================
// Task Provider
// ============================================================================

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]);

  void load() {
    state = DatabaseService.getAllTasks();
  }

  Future<void> add({
    required String title,
    String description = '',
    required TaskCategory category,
    String? assigneeId,
    DateTime? deadline,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: category,
      assigneeId: assigneeId,
      deadline: deadline,
      createdAt: DateTime.now(),
    );
    await DatabaseService.saveTask(task);
    state = [...state, task];
  }

  Future<void> update(Task task) async {
    await DatabaseService.saveTask(task);
    state = state.map((t) => t.id == task.id ? task : t).toList();
  }

  Future<void> toggleStatus(String id) async {
    final task = state.firstWhere((t) => t.id == id);
    final updated = task.copyWith(status: task.nextStatus);
    await update(updated);
  }

  Future<void> delete(String id) async {
    await DatabaseService.deleteTask(id);
    state = state.where((t) => t.id != id).toList();
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

// ============================================================================
// Packing Providers (Room, PackingBox, BoxItem)
// ============================================================================

class RoomNotifier extends StateNotifier<List<Room>> {
  RoomNotifier() : super([]);

  void load() {
    state = DatabaseService.getAllRooms();
  }

  Future<void> add({
    required String name,
    String icon = '📦',
    String color = '#6366F1',
    double? budget,
  }) async {
    final room = Room(
      id: _uuid.v4(),
      name: name,
      icon: icon,
      color: color,
      budget: budget,
      createdAt: DateTime.now(),
    );
    await DatabaseService.saveRoom(room);
    state = [...state, room];
  }

  Future<void> update(Room room) async {
    await DatabaseService.saveRoom(room);
    state = state.map((r) => r.id == room.id ? room : r).toList();
  }

  Future<void> delete(String id) async {
    await DatabaseService.deleteRoom(id);
    state = state.where((r) => r.id != id).toList();
  }
}

final roomProvider = StateNotifierProvider<RoomNotifier, List<Room>>((ref) {
  return RoomNotifier();
});

class BoxNotifier extends StateNotifier<List<PackingBox>> {
  BoxNotifier() : super([]);

  void load() {
    state = DatabaseService.getAllBoxes();
  }

  Future<void> add({
    required String roomId,
    required String label,
    bool isFragile = false,
  }) async {
    final box = PackingBox(
      id: _uuid.v4(),
      roomId: roomId,
      label: label,
      isFragile: isFragile,
      createdAt: DateTime.now(),
    );
    await DatabaseService.saveBox(box);
    state = [...state, box];
  }

  Future<void> update(PackingBox box) async {
    await DatabaseService.saveBox(box);
    state = state.map((b) => b.id == box.id ? box : b).toList();
  }

  Future<void> delete(String id) async {
    await DatabaseService.deleteBox(id);
    state = state.where((b) => b.id != id).toList();
  }
}

final boxProvider = StateNotifierProvider<BoxNotifier, List<PackingBox>>((ref) {
  return BoxNotifier();
});

class BoxItemNotifier extends StateNotifier<List<BoxItem>> {
  BoxItemNotifier() : super([]);

  void load() {
    state = DatabaseService.getAllBoxItems();
  }

  Future<void> add({
    required String boxId,
    required String name,
    int quantity = 1,
    double? estimatedValue,
  }) async {
    final item = BoxItem(
      id: _uuid.v4(),
      boxId: boxId,
      name: name,
      quantity: quantity,
      estimatedValue: estimatedValue,
      createdAt: DateTime.now(),
    );
    await DatabaseService.saveBoxItem(item);
    state = [...state, item];
  }

  Future<void> update(BoxItem item) async {
    await DatabaseService.saveBoxItem(item);
    state = state.map((i) => i.id == item.id ? item : i).toList();
  }

  Future<void> delete(String id) async {
    await DatabaseService.deleteBoxItem(id);
    state = state.where((i) => i.id != id).toList();
  }
}

final boxItemProvider = StateNotifierProvider<BoxItemNotifier, List<BoxItem>>((ref) {
  return BoxItemNotifier();
});

// ============================================================================
// Shopping Provider
// ============================================================================

class ShoppingNotifier extends StateNotifier<List<ShoppingItem>> {
  ShoppingNotifier() : super([]);

  void load() {
    state = DatabaseService.getAllShoppingItems();
  }

  Future<void> add({
    required String name,
    String? roomId,
    ShoppingPriority priority = ShoppingPriority.medium,
    double? budgetMin,
    double? budgetMax,
  }) async {
    final item = ShoppingItem(
      id: _uuid.v4(),
      name: name,
      roomId: roomId,
      priority: priority,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      createdAt: DateTime.now(),
    );
    await DatabaseService.saveShoppingItem(item);
    state = [...state, item];
  }

  Future<void> update(ShoppingItem item) async {
    await DatabaseService.saveShoppingItem(item);
    state = state.map((i) => i.id == item.id ? item : i).toList();
  }

  Future<void> updateStatus(String id, ShoppingStatus status) async {
    final item = state.firstWhere((i) => i.id == id);
    final updated = item.copyWith(status: status);
    await update(updated);
  }

  Future<void> delete(String id) async {
    await DatabaseService.deleteShoppingItem(id);
    state = state.where((i) => i.id != id).toList();
  }
}

final shoppingProvider = StateNotifierProvider<ShoppingNotifier, List<ShoppingItem>>((ref) {
  return ShoppingNotifier();
});

// ============================================================================
// Expense Provider
// ============================================================================

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier() : super([]);

  void load() {
    state = DatabaseService.getAllExpenses();
  }

  Future<void> add({
    required String description,
    required double amount,
    required ExpenseCategory category,
    required String paidById,
    required List<String> splitBetweenIds,
    DateTime? date,
  }) async {
    final expense = Expense(
      id: _uuid.v4(),
      description: description,
      amount: amount,
      category: category,
      paidById: paidById,
      splitBetweenIds: splitBetweenIds,
      date: date ?? DateTime.now(),
      createdAt: DateTime.now(),
    );
    await DatabaseService.saveExpense(expense);
    state = [...state, expense];
  }

  Future<void> update(Expense expense) async {
    await DatabaseService.saveExpense(expense);
    state = state.map((e) => e.id == expense.id ? expense : e).toList();
  }

  Future<void> delete(String id) async {
    await DatabaseService.deleteExpense(id);
    state = state.where((e) => e.id != id).toList();
  }

  double get totalExpenses => state.fold(0.0, (sum, e) => sum + e.amount);
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>((ref) {
  return ExpenseNotifier();
});

// ============================================================================
// Playbook Providers
// ============================================================================

class JournalNotifier extends StateNotifier<List<JournalEntry>> {
  JournalNotifier() : super([]);

  void load() {
    state = DatabaseService.getAllJournalEntries()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> log({
    required JournalEventType type,
    required String title,
    String? description,
    String? userId,
    String? relatedEntityId,
  }) async {
    final entry = JournalEntry(
      id: _uuid.v4(),
      type: type,
      title: title,
      description: description,
      userId: userId,
      relatedEntityId: relatedEntityId,
      timestamp: DateTime.now(),
    );
    await DatabaseService.saveJournalEntry(entry);
    state = [entry, ...state];
  }
}

final journalProvider = StateNotifierProvider<JournalNotifier, List<JournalEntry>>((ref) {
  return JournalNotifier();
});

class NotesNotifier extends StateNotifier<List<PlaybookNote>> {
  NotesNotifier() : super([]);

  void load() {
    state = DatabaseService.getAllNotes();
  }

  Future<void> add({
    required String title,
    required String content,
    String? category,
  }) async {
    final note = PlaybookNote(
      id: _uuid.v4(),
      title: title,
      content: content,
      category: category,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await DatabaseService.saveNote(note);
    state = [...state, note];
  }

  Future<void> update(PlaybookNote note) async {
    await DatabaseService.saveNote(note);
    state = state.map((n) => n.id == note.id ? note : n).toList();
  }

  Future<void> togglePin(String id) async {
    final note = state.firstWhere((n) => n.id == id);
    final updated = note.copyWith(isPinned: !note.isPinned);
    await update(updated);
  }

  Future<void> delete(String id) async {
    await DatabaseService.deleteNote(id);
    state = state.where((n) => n.id != id).toList();
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, List<PlaybookNote>>((ref) {
  return NotesNotifier();
});
