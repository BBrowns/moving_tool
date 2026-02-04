import 'package:moving_tool_flutter/features/tasks/data/repositories/tasks_repository_impl.dart';
import 'package:moving_tool_flutter/features/tasks/domain/entities/task.dart';
import 'package:moving_tool_flutter/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'task_providers.g.dart';

const _uuid = Uuid();

// ============================================================================
// Repository Provider
// ============================================================================

@Riverpod(keepAlive: true)
TasksRepository tasksRepository(Ref ref) {
  return TasksRepositoryImpl();
}

// Generated provider: tasksRepositoryProvider

// ============================================================================
// Task Notifier
// ============================================================================

@Riverpod(keepAlive: true)
class TaskNotifier extends _$TaskNotifier {
  late final TasksRepository repository;

  @override
  List<Task> build() {
    repository = ref.watch(tasksRepositoryProvider);
    return [];
  }

  Future<void> load() async {
    state = await repository.getTasks(); // Update usage
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
    await repository.saveTask(task); // Update usage
    state = [...state, task];
  }

  Future<void> update(Task task) async {
    await repository.saveTask(task); // Update usage
    state = state.map((t) => t.id == task.id ? task : t).toList();
  }

  Future<void> toggleStatus(String id) async {
    final task = state.firstWhere((t) => t.id == id);
    final updated = task.copyWith(status: task.nextStatus);
    await update(updated);
  }

  Future<void> updateStatus(String id, TaskStatus status) async {
    final task = state.firstWhere((t) => t.id == id);
    if (task.status != status) {
      final updated = task.copyWith(status: status);
      await update(updated);
    }
  }

  Future<void> delete(String id) async {
    await repository.deleteTask(id); // Update usage
    state = state.where((t) => t.id != id).toList();
  }
}
