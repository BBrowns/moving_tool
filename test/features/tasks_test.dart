// Tasks Screen Tests
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moving_tool_flutter/data/providers/providers.dart';
import 'package:moving_tool_flutter/core/models/models.dart';
import 'package:moving_tool_flutter/features/tasks/tasks_screen.dart';
import 'package:moving_tool_flutter/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:moving_tool_flutter/features/tasks/presentation/providers/task_providers.dart';

// Mock Repository used by Real TaskNotifier
class MockTasksRepository implements TasksRepository {
  List<Task> _tasks = [];

  MockTasksRepository([List<Task>? initialTasks]) {
    if (initialTasks != null) {
      _tasks = initialTasks;
    }
  }

  @override
  Future<List<Task>> getTasks() async => _tasks;
  
  @override
  Future<void> saveTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
    } else {
      _tasks.add(task);
    }
  }
  
  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
  }
}

class TestTaskNotifier extends TaskNotifier {
  final List<Task> _initialTasks;
  
  TestTaskNotifier(this._initialTasks);
  
  @override
  List<Task> build() {
    repository = ref.watch(tasksRepositoryProvider);
    return _initialTasks;
  }
}

void main() {
  group('TasksScreen', () {
    testWidgets('shows empty state when no tasks exist', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
             tasksRepositoryProvider.overrideWithValue(MockTasksRepository()),
             taskProvider.overrideWith(() => TestTaskNotifier([])),
          ],
          child: const MaterialApp(
            home: TasksScreen(),
          ),
        ),
      );

      expect(find.text('📝'), findsOneWidget);
      expect(find.text('Nog geen taken'), findsOneWidget);
    });

    testWidgets('Mobile: shows List View grouped by Category', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockTask = Task(
        id: '1',
        title: 'Test Task',
        category: TaskCategory.administratie,
        status: TaskStatus.todo,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksRepositoryProvider.overrideWithValue(MockTasksRepository([mockTask])),
            taskProvider.overrideWith(() => TestTaskNotifier([mockTask])),
          ],
          child: const MaterialApp(
            home: TasksScreen(),
          ),
        ),
      );

      await tester.pump();

      // Should find Category Header (Icon is separate)
      expect(find.text('Administratie'), findsOneWidget);
      // Should find Task Title
      expect(find.text('Test Task'), findsOneWidget);
      // Should find ListView
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Desktop: shows Kanban View grouped by Status', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockTask = Task(
        id: '1',
        title: 'Test Task',
        category: TaskCategory.administratie,
        status: TaskStatus.todo,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksRepositoryProvider.overrideWithValue(MockTasksRepository([mockTask])),
            taskProvider.overrideWith(() => TestTaskNotifier([mockTask])),
          ],
          child: const MaterialApp(
            home: TasksScreen(),
          ),
        ),
      );

      await tester.pump();

      // Should find Status Labels
      expect(find.text('Te doen'), findsOneWidget);
      expect(find.text('Bezig'), findsOneWidget);
      expect(find.text('Klaar'), findsOneWidget);

      // Should find Task Title
      expect(find.text('Test Task'), findsOneWidget);
    });

    testWidgets('Add Task Dialog works', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksRepositoryProvider.overrideWithValue(MockTasksRepository()),
            taskProvider.overrideWith(() => TestTaskNotifier([])),
          ],
          child: const MaterialApp(
            home: TasksScreen(),
          ),
        ),
      );

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Nieuwe taak'), findsOneWidget);
      
      // Enter text
      await tester.enterText(find.byType(TextField).first, 'New Task');
      await tester.tap(find.text('Toevoegen'));
      await tester.pumpAndSettle();

      // Dialog closed and task added
      expect(find.text('Nieuwe taak'), findsNothing);
      expect(find.text('New Task'), findsOneWidget);
    });

    testWidgets('Filtering by Category works', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final task1 = Task(
        id: '1',
        title: 'Admin Task',
        category: TaskCategory.administratie,
        status: TaskStatus.todo,
        createdAt: DateTime.now(),
      );
      final task2 = Task(
        id: '2',
        title: 'Clean Task',
        category: TaskCategory.schoonmaken,
        status: TaskStatus.todo,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksRepositoryProvider.overrideWithValue(MockTasksRepository([task1, task2])),
            taskProvider.overrideWith(() => TestTaskNotifier([task1, task2])),
          ],
          child: const MaterialApp(
            home: TasksScreen(),
          ),
        ),
      );

      await tester.pump();
      
      // Initially both visible
      expect(find.text('Admin Task'), findsOneWidget);
      expect(find.text('Clean Task'), findsOneWidget);

      // Open Filter Menu
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Select 'Administratie'
      await tester.tap(find.text('📋 Administratie'));
      await tester.pumpAndSettle();

      // Verify filtering
      expect(find.text('Admin Task'), findsOneWidget);
      expect(find.text('Clean Task'), findsNothing);
      
      // Clear filter using the X button
      await tester.tap(find.byIcon(Icons.filter_alt_off));
      await tester.pumpAndSettle();
      
      expect(find.text('Clean Task'), findsOneWidget);
    });
  });
}
