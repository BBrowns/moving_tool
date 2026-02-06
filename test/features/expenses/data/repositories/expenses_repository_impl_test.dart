import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moving_tool_flutter/core/error/exceptions.dart';
import 'package:moving_tool_flutter/features/expenses/data/datasources/expenses_local_data_source.dart';
import 'package:moving_tool_flutter/features/expenses/data/repositories/expenses_repository_impl.dart';
import 'package:moving_tool_flutter/features/expenses/domain/entities/expense.dart';

@GenerateNiceMocks([MockSpec<ExpensesLocalDataSource>()])
import 'expenses_repository_impl_test.mocks.dart';

void main() {
  late ExpensesRepositoryImpl repository;
  late MockExpensesLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockExpensesLocalDataSource();
    repository = ExpensesRepositoryImpl(mockDataSource);
  });

  group('getExpenses', () {
    const tProjectId = 'project1';
    final tExpenses = [
      Expense(
        id: '1',
        projectId: 'project1',
        description: 'Test 1',
        amount: 10,
        category: ExpenseCategory.other,
        paidById: 'u1',
        splitBetweenIds: ['u1'],
        date: DateTime.now(),
        createdAt: DateTime.now(),
      ),
      Expense(
        id: '2',
        projectId: 'project2', // Different project
        description: 'Test 2',
        amount: 20,
        category: ExpenseCategory.food,
        paidById: 'u2',
        splitBetweenIds: ['u2'],
        date: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    ];

    test('should return only expenses for the given project id', () async {
      // Arrange
      when(mockDataSource.getAllExpenses()).thenAnswer((_) async => tExpenses);

      // Act
      final result = await repository.getExpenses(tProjectId);

      // Assert
      expect(result.length, 1);
      expect(result.first.id, '1');
      verify(mockDataSource.getAllExpenses());
    });

    test('should throw FetchFailure when data source throws', () async {
      // Arrange
      when(mockDataSource.getAllExpenses()).thenThrow(Exception('DB Error'));

      // Act & Assert
      expect(
        () => repository.getExpenses(tProjectId),
        throwsA(isA<FetchFailure>()),
      );
    });
  });

  group('saveExpense', () {
    final tExpense = Expense(
      id: '1',
      projectId: 'project1',
      description: 'Test 1',
      amount: 10,
      category: ExpenseCategory.other,
      paidById: 'u1',
      splitBetweenIds: ['u1'],
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );

    test('should call saveExpense on data source', () async {
      // Act
      await repository.saveExpense(tExpense);

      // Assert
      verify(mockDataSource.saveExpense(tExpense));
    });

    test('should throw SaveFailure when data source throws', () async {
      // Arrange
      when(mockDataSource.saveExpense(any)).thenThrow(Exception('DB Error'));

      // Act & Assert
      expect(
        () => repository.saveExpense(tExpense),
        throwsA(isA<SaveFailure>()),
      );
    });
  });
}
