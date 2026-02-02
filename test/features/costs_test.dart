import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moving_tool_flutter/data/providers/providers.dart';
import 'package:moving_tool_flutter/core/models/models.dart';
import 'package:moving_tool_flutter/features/expenses/expenses_screen.dart';

import 'package:moving_tool_flutter/features/expenses/presentation/providers/expense_providers.dart';
import 'package:moving_tool_flutter/features/projects/presentation/providers/project_providers.dart';

// Fake Expect Notifier
class FakeExpenseNotifier extends ExpenseNotifier {
  final List<Expense> _initial;
  FakeExpenseNotifier([List<Expense>? initialExpenses]) : _initial = initialExpenses ?? [];

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
  }) async {
    state = [
      ...state,
      Expense(
        id: 'new',
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
  final Project? _initial;
  FakeProjectNotifier([this._initial]);

  @override
  Project? build() => _initial;
}

void main() {
  group('CostsScreen', () {
    final mockUser = User(id: 'u1', name: 'Julian', color: '#000000');
    final mockProject = Project(id: 'p1', name: 'Test Move', users: [mockUser], createdAt: DateTime.now(), movingDate: DateTime.now(), fromAddress: Address(), toAddress: Address());
    
    final mockExpense = Expense(
      id: 'e1',
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
            expenseProvider.overrideWith(() => FakeExpenseNotifier([mockExpense])),
            projectProvider.overrideWith(() => FakeProjectNotifier(mockProject)),
          ],
          child: const MaterialApp(home: ExpensesScreen()),
        ),
      );

      // Verify List Tab (Default)
      expect(find.text('Moving Van'), findsOneWidget);
      expect(find.text('€100.00'), findsOneWidget);

      // Switch to Summary Tab
      await tester.tap(find.text('Overzicht'));
      await tester.pumpAndSettle();

      expect(find.text('Totaal uitgegeven'), findsOneWidget);
      // It appears in Total Card AND in Category List
      expect(find.text('€100.00'), findsNWidgets(2));
    });

    testWidgets('Add Expense Dialog works', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseProvider.overrideWith(() => FakeExpenseNotifier([])),
            projectProvider.overrideWith(() => FakeProjectNotifier(mockProject)),
          ],
          child: const MaterialApp(home: ExpensesScreen()),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Nieuwe uitgave'), findsOneWidget);
      
      await tester.enterText(find.widgetWithText(TextField, 'Omschrijving'), 'Pizza');
      await tester.enterText(find.widgetWithText(TextField, 'Bedrag'), '50');
      
      await tester.tap(find.text('Toevoegen'));
      await tester.pumpAndSettle();

      expect(find.text('Pizza'), findsOneWidget);
      expect(find.text('€50.00'), findsOneWidget);
    });
  });
}
