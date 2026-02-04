import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moving_tool_flutter/core/models/models.dart';
import 'package:moving_tool_flutter/data/providers/providers.dart';
import 'package:moving_tool_flutter/features/expenses/expenses_screen.dart';

// Fake Expect Notifier
class FakeExpenseNotifier extends ExpenseNotifier {
  FakeExpenseNotifier([List<Expense>? initialExpenses])
    : _initial = initialExpenses ?? [];
  final List<Expense> _initial;

  @override
  List<Expense> build() => _initial;

  @override
  Future<void> add({
    required String description,
    required double amount,
    required ExpenseCategory category,
    required String paidById,
    required List<String> splitBetweenIds,
    DateTime? date,
    String notes = '',
  }) async {
    state = [
      ...state,
      Expense(
        id: 'new',
        projectId: 'p1',
        description: description,
        amount: amount,
        category: category,
        paidById: paidById,
        splitBetweenIds: splitBetweenIds,
        date: date ?? DateTime.now(),
        createdAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<void> delete(String id) async {
    state = state.where((e) => e.id != id).toList();
  }
}

// Fake Project Notifier
class FakeProjectNotifier extends ProjectNotifier {
  FakeProjectNotifier([this._initial]);
  final Project? _initial;

  @override
  Project? build() => _initial;
}

void main() {
  group('CostsScreen', () {
    final mockUser = const ProjectMember(
      id: 'u1',
      name: 'Julian',
      role: ProjectRole.admin,
      color: '#000000',
    );
    final mockProject = Project(
      id: 'p1',
      name: 'Test Move',
      members: [mockUser],
      createdAt: DateTime.now(),
      movingDate: DateTime.now(),
      fromAddress: const Address(),
      toAddress: const Address(),
    );

    final mockExpense = Expense(
      id: 'e1',
      projectId: 'p1',
      description: 'Moving Van',
      amount: 100.0,
      category: ExpenseCategory.verhuizing,
      paidById: 'u1',
      splitBetweenIds: ['u1'],
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );

    testWidgets('Shows expenses list and summary', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseProvider.overrideWith(
              () => FakeExpenseNotifier([mockExpense]),
            ),
            projectProvider.overrideWith(
              () => FakeProjectNotifier(mockProject),
            ),
          ],
          child: const MaterialApp(home: ExpensesScreen()),
        ),
      );

      // Verify Expenses List
      expect(find.text('Moving Van'), findsOneWidget);
      expect(find.textContaining('€100'), findsOneWidget);

      // Verify Balance Header (Total)
      expect(find.text('Totaal uitgegeven'), findsOneWidget);
      // It might appear multiple times if detailed in breakdown, but at least once in header
      expect(find.textContaining('€100'), findsAtLeastNWidgets(1));
    });

    testWidgets('Add Expense Dialog works', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseProvider.overrideWith(() => FakeExpenseNotifier([])),
            projectProvider.overrideWith(
              () => FakeProjectNotifier(mockProject),
            ),
          ],
          child: const MaterialApp(home: ExpensesScreen()),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Nieuwe uitgave'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Omschrijving'),
        'Pizza',
      );
      await tester.enterText(find.widgetWithText(TextField, 'Bedrag'), '50');

      await tester.tap(find.text('Toevoegen'));
      await tester.pumpAndSettle();

      expect(find.text('Pizza'), findsOneWidget);
      expect(find.textContaining('€50'), findsOneWidget);
    });
  });
}
