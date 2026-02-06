import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moving_tool_flutter/core/models/models.dart';
import 'package:moving_tool_flutter/features/expenses/presentation/providers/expense_providers.dart';
import 'package:moving_tool_flutter/features/packing/presentation/providers/packing_providers.dart';
import 'package:moving_tool_flutter/features/playbook/presentation/providers/playbook_providers.dart';
import 'package:moving_tool_flutter/features/projects/presentation/providers/project_providers.dart';
import 'package:moving_tool_flutter/features/shopping/presentation/providers/shopping_providers.dart';
import 'package:moving_tool_flutter/features/tasks/presentation/providers/task_providers.dart';
import 'package:moving_tool_flutter/main.dart';

// Fake Notifiers that do nothing on load to prevent crashes
class FakeProjectNotifier extends ProjectNotifier {
  FakeProjectNotifier(this._initial);
  final Project? _initial;
  @override
  Project? build() => _initial;
  @override
  Future<void> load() async {}
}

class FakeProjectsNotifier extends ProjectsNotifier {
  @override
  List<Project> build() => [];
  @override
  Future<void> load() async {}
}

class FakeTaskNotifier extends TaskNotifier {
  @override
  List<Task> build() => [];
  @override
  Future<void> load() async {}
}

class FakeShoppingNotifier extends ShoppingNotifier {
  @override
  List<ShoppingItem> build() => [];
  @override
  Future<void> load() async {}
}

class FakeExpenseNotifier extends ExpenseNotifier {
  @override
  List<Expense> build() => [];
  @override
  Future<void> load() async {}
}

class FakeRoomNotifier extends RoomNotifier {
  @override
  List<Room> build() => [];
  @override
  Future<void> load() async {}
}

class FakeBoxNotifier extends BoxNotifier {
  @override
  List<PackingBox> build() => [];
  @override
  Future<void> load() async {}
}

class FakeBoxItemNotifier extends BoxItemNotifier {
  @override
  List<BoxItem> build() => [];
  @override
  Future<void> load() async {}
}

class FakeJournalNotifier extends JournalNotifier {
  @override
  List<JournalEntry> build() => [];
  @override
  Future<void> load() async {}
}

class FakeNotesNotifier extends NotesNotifier {
  @override
  List<PlaybookNote> build() => [];
  @override
  Future<void> load() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockProject = Project(
    id: '1',
    name: 'Test Move',
    movingDate: DateTime.now().add(const Duration(days: 30)),
    fromAddress: const Address(),
    toAddress: const Address(),
    createdAt: DateTime.now(),
    members: [],
  );

  final overrides = [
    projectsProvider.overrideWith(FakeProjectsNotifier.new),
    taskProvider.overrideWith(FakeTaskNotifier.new),
    shoppingProvider.overrideWith(FakeShoppingNotifier.new),
    expenseProvider.overrideWith(FakeExpenseNotifier.new),
    roomProvider.overrideWith(FakeRoomNotifier.new),
    boxProvider.overrideWith(FakeBoxNotifier.new),
    boxItemProvider.overrideWith(FakeBoxItemNotifier.new),
    journalProvider.overrideWith(FakeJournalNotifier.new),
    notesProvider.overrideWith(FakeNotesNotifier.new),
  ];

  group('App Navigation', () {
    testWidgets('Redirects to Onboarding when no project active', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...overrides,
            projectProvider.overrideWith(() => FakeProjectNotifier(null)),
          ],
          child: const MovingToolApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welkom bij Verhuistool'), findsOneWidget);
    });

    testWidgets('Redirects to Dashboard when project active', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...overrides,
            projectProvider.overrideWith(
              () => FakeProjectNotifier(mockProject),
            ),
          ],
          child: const MovingToolApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mijn Verhuizingen'), findsNothing);
      expect(find.text('Hallo Verhuizer! 👋'), findsOneWidget);
    });

    testWidgets('Can navigate to Projects screen even if project active', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...overrides,
            projectProvider.overrideWith(
              () => FakeProjectNotifier(mockProject),
            ),
          ],
          child: const MovingToolApp(),
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.text('Hallo Verhuizer! 👋'));
      GoRouter.of(context).go('/projects');
      await tester.pumpAndSettle();

      expect(find.text('Mijn Verhuizingen'), findsOneWidget);
    });
  });
}
