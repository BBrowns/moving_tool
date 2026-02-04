import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:moving_tool_flutter/features/dashboard/dashboard_screen.dart';
import 'package:moving_tool_flutter/features/expenses/domain/entities/expense.dart';
import 'package:moving_tool_flutter/features/expenses/domain/entities/settlement_batch.dart';
import 'package:moving_tool_flutter/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:moving_tool_flutter/features/expenses/presentation/providers/expense_providers.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/box_item.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/packing_box.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/room.dart';
// Reuse Mock Repository logic (simplified for integration test)
import 'package:moving_tool_flutter/features/packing/domain/repositories/packing_repository.dart';
import 'package:moving_tool_flutter/features/packing/packing_screen.dart';
import 'package:moving_tool_flutter/features/packing/presentation/providers/packing_providers.dart';
import 'package:moving_tool_flutter/features/playbook/domain/entities/journal_entry.dart';
import 'package:moving_tool_flutter/features/playbook/domain/entities/playbook_note.dart';
import 'package:moving_tool_flutter/features/playbook/domain/repositories/playbook_repository.dart';
import 'package:moving_tool_flutter/features/playbook/presentation/providers/playbook_providers.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';
import 'package:moving_tool_flutter/features/projects/domain/repositories/projects_repository.dart';
import 'package:moving_tool_flutter/features/projects/presentation/providers/project_providers.dart';
import 'package:moving_tool_flutter/features/shopping/domain/entities/shopping_item.dart';
import 'package:moving_tool_flutter/features/shopping/domain/repositories/shopping_repository.dart';
import 'package:moving_tool_flutter/features/shopping/presentation/providers/shopping_providers.dart';
import 'package:moving_tool_flutter/features/tasks/domain/entities/task.dart';
import 'package:moving_tool_flutter/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:moving_tool_flutter/features/tasks/presentation/providers/task_providers.dart';
import 'package:moving_tool_flutter/main.dart'; // To get the main App widget if available, or reconstruct

// Manual Mocks for All Repositories
class MockTasksRepository extends Mock implements TasksRepository {
  @override
  Future<List<Task>> getTasks() async => [];
  @override
  Future<void> saveTask(Task task) async {}
  @override
  Future<void> deleteTask(String id) async {}
}

class MockShoppingRepository extends Mock implements ShoppingRepository {
  @override
  Future<List<ShoppingItem>> getItems() async => [];
  @override
  Future<void> saveItem(ShoppingItem item) async {}
  @override
  Future<void> deleteItem(String id) async {}
}

class MockExpensesRepository extends Mock implements ExpensesRepository {
  @override
  Future<List<Expense>> getExpenses() async => [];
  @override
  Future<void> saveExpense(Expense expense) async {}
  @override
  Future<void> deleteExpense(String id) async {}
  @override
  Future<List<SettlementBatch>> getSettlementBatches() async => [];
  @override
  Future<void> saveSettlementBatch(SettlementBatch batch) async {}
  @override
  Future<void> deleteSettlementBatch(String id) async {}
}

// Manual Mock for PlaybookRepository
class MockPlaybookRepository extends Mock implements PlaybookRepository {
  @override
  Future<List<JournalEntry>> getJournalEntries() async => [];
  
  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {}
  
  @override
  Future<List<PlaybookNote>> getNotes() async => [];
  
  @override
  Future<void> saveNote(PlaybookNote note) async {}
  
  @override
  Future<void> deleteNote(String id) async {}
}

// Manual Mock for ProjectsRepository
class MockProjectsRepository extends Mock implements ProjectsRepository {
  final _testProject = Project(
    id: 'test-project',
    name: 'Test Project',
    createdAt: DateTime.now(),
    movingDate: DateTime.now().add(const Duration(days: 30)),
    fromAddress: Address(city: 'Old City'),
    toAddress: Address(city: 'New City'),
    users: [],
  );

  @override
  List<Project> getAllProjects() => [_testProject];
  
  @override
  Project? getActiveProject() => _testProject;
  
  @override
  Future<void> saveProject(Project project) async {}
  
  @override
  Future<void> setActiveProject(String id) async {}

  @override
  Future<void> deleteProject(String id) async {}
}

// Manual Mock for speed
class IntegrationMockRepository extends Mock implements PackingRepository {
  final List<Room> _rooms = [];
  final List<PackingBox> _boxes = [];

  @override
  Future<List<Room>> getRooms() async => _rooms;
  @override
  Future<List<PackingBox>> getBoxes() async => _boxes;
  @override
  Future<List<BoxItem>> getItems() async => []; // Empty for now

  @override
  Future<void> saveRoom(Room room) async {
    _rooms.add(room);
  }

  @override
  Future<void> saveBox(PackingBox box) async {
    _boxes.add(box);
  }

  @override
  Future<void> deleteBox(String id) async {}
  
  @override
  Future<void> deleteItem(String id) async {}
  
  @override
  Future<void> deleteRoom(String id) async {}
  
  @override
  Future<void> saveItem(BoxItem item) async {}
}

void main() {
  testWidgets('Integration: Full User Journey (Dashboard -> Packing -> Add Box)', (WidgetTester tester) async {
    // 1. Setup Data & Providers
    final mockRepo = IntegrationMockRepository();
    // Pre-populate a room so we can add a box to it
    final livingRoom = Room(
      id: 'room-1', 
      name: 'Woonkamer', 
      icon: '🛋️', 
      color: 'Blue', 
      createdAt: DateTime.now()
    );
    await mockRepo.saveRoom(livingRoom);
    
    final mockProjectsRepo = MockProjectsRepository();
    final mockPlaybookRepo = MockPlaybookRepository();
    final mockTasksRepo = MockTasksRepository();
    final mockShoppingRepo = MockShoppingRepository();
    final mockExpensesRepo = MockExpensesRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          packingRepositoryProvider.overrideWithValue(mockRepo),
          projectsRepositoryProvider.overrideWithValue(mockProjectsRepo),
          playbookRepositoryProvider.overrideWithValue(mockPlaybookRepo),
          tasksRepositoryProvider.overrideWithValue(mockTasksRepo),
          shoppingRepositoryProvider.overrideWithValue(mockShoppingRepo),
          expensesRepositoryProvider.overrideWithValue(mockExpensesRepo),
        ],
        child: const MovingToolApp(), // Ensure this matches your main.dart App class
      ),
    );
    await tester.pumpAndSettle(); // Allow router to settle

    // 2. We start at Dashboard (Verify)
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);

    // 3. Navigate to Packing (Using NavigationBar/Rail)
    // Find icon with Packing label/icon
    final packingIcon = find.byIcon(Icons.inventory_2_rounded).first; 
    await tester.tap(packingIcon);
    await tester.pumpAndSettle();

    // Verify we are on Packing Screen
    expect(find.byType(PackingScreen), findsOneWidget);
    expect(find.text('Woonkamer'), findsOneWidget); // Pre-populated room visible?

    // 4. Click Add Box (on the Room Card)
    // Finding the 'Add Box' button on the specific room card
    // Icon is usually add_box_outlined or similar
    final addBoxButton = find.byIcon(Icons.add_box_outlined).first;
    await tester.tap(addBoxButton);
    await tester.pumpAndSettle();

    // 5. Fill Dialog
    expect(find.text('Nieuwe doos'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Boeken en CDs');
    
    // 6. Save
    await tester.tap(find.text('Toevoegen'));
    await tester.pumpAndSettle();

    // 7. Verify New Box is in the list
    // Room Card only shows stats, so we tap the card to see details
    await tester.tap(find.text('Woonkamer'));
    await tester.pumpAndSettle();

    // Now inside the BottomSheet, we should see the box
    // Might find 2 if TextField is fading out or similar (Text in field + Text in Tile)
    expect(find.text('Boeken en CDs'), findsAtLeastNWidgets(1));
    
    // Close the sheet
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // 8. Go back to Dashboard
    final dashboardIcon = find.byIcon(Icons.dashboard_rounded).first;
    await tester.tap(dashboardIcon);
    await tester.pumpAndSettle();
    
    expect(find.byType(DashboardScreen), findsOneWidget);

    // 9. Return to packing (Persistence Check)
    await tester.tap(packingIcon);
    await tester.pumpAndSettle();
    
    // Tap room again to see details
    await tester.tap(find.text('Woonkamer'));
    await tester.pumpAndSettle();

    // Box should still be there
    expect(find.text('Boeken en CDs'), findsAtLeastNWidgets(1));
  });
}
