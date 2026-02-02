// Provider Unit Tests
import 'package:flutter_test/flutter_test.dart';
import 'package:moving_tool_flutter/core/models/models.dart';

void main() {
  group('Project Model', () {
    test('daysUntilMove calculates correctly', () {
      final project = Project(
        id: 'test-id',
        name: 'Test Move',
        movingDate: DateTime.now().add(const Duration(days: 15)),
        fromAddress: Address(),
        toAddress: Address(),
        users: [],
        createdAt: DateTime.now(),
      );

      // Using closeTo to handle timezone/time-of-day variations
      expect(project.daysUntilMove, closeTo(15, 1));
    });

    test('daysUntilMove returns 0 for past dates', () {
      final project = Project(
        id: 'test-id',
        name: 'Test Move',
        movingDate: DateTime.now().subtract(const Duration(days: 5)),
        fromAddress: Address(),
        toAddress: Address(),
        users: [],
        createdAt: DateTime.now(),
      );

      expect(project.daysUntilMove, lessThanOrEqualTo(0));
    });

    test('copyWith creates new instance with updated values', () {
      final project = Project(
        id: 'test-id',
        name: 'Original Name',
        movingDate: DateTime.now(),
        fromAddress: Address(),
        toAddress: Address(),
        users: [],
        createdAt: DateTime.now(),
      );

      final updated = project.copyWith(name: 'Updated Name');

      expect(updated.name, 'Updated Name');
      expect(updated.id, project.id); // Should keep original id
    });
  });

  group('Task Model', () {
    test('nextStatus cycles through statuses correctly', () {
      final task = Task(
        id: 'task-1',
        title: 'Test Task',
        description: '',
        category: TaskCategory.overig,
        status: TaskStatus.todo,
        createdAt: DateTime.now(),
      );

      // todo -> inProgress
      var next = task.copyWith(status: task.nextStatus);
      expect(next.status, TaskStatus.inProgress);

      // inProgress -> done
      next = next.copyWith(status: next.nextStatus);
      expect(next.status, TaskStatus.done);
    });
  });

  group('PackingBox Model', () {
    test('creates box with correct default status', () {
      final box = PackingBox(
        id: 'box-1',
        roomId: 'room-1',
        label: 'Test Box',
        isFragile: false,
        createdAt: DateTime.now(),
      );

      expect(box.status, BoxStatus.empty);
    });

    test('fragile flag is set correctly', () {
      final box = PackingBox(
        id: 'box-1',
        roomId: 'room-1',
        label: 'Fragile Box',
        isFragile: true,
        createdAt: DateTime.now(),
      );

      expect(box.isFragile, true);
    });
  });

  group('Room Model', () {
    test('creates room with required fields', () {
      final room = Room(
        id: 'room-1',
        name: 'Living Room',
        icon: '🛋️',
        color: '#6366F1',
        createdAt: DateTime.now(),
      );

      expect(room.name, 'Living Room');
      expect(room.icon, '🛋️');
    });
  });

  group('ShoppingItem Model', () {
    test('creates item with default status needed', () {
      final item = ShoppingItem(
        id: 'item-1',
        name: 'New Couch',
        priority: ShoppingPriority.high,
        createdAt: DateTime.now(),
      );

      expect(item.status, ShoppingStatus.needed);
    });
  });

  group('Expense Model', () {
    test('creates expense with correct category', () {
      final expense = Expense(
        id: 'expense-1',
        description: 'Moving Van',
        amount: 500.0,
        category: ExpenseCategory.verhuizing,
        paidById: 'user-1',
        splitBetweenIds: ['user-1', 'user-2'],
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(expense.amount, 500.0);
      expect(expense.category, ExpenseCategory.verhuizing);
    });
  });
}
