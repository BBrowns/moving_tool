import 'package:moving_tool_flutter/data/services/database_service.dart';
import 'package:moving_tool_flutter/features/tasks/domain/entities/task.dart';
import 'package:moving_tool_flutter/features/tasks/domain/repositories/tasks_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  @override
  Future<List<Task>> getTasks() async {
    return DatabaseService.getAllTasks();
  }

  @override
  Future<void> saveTask(Task task) async {
    return DatabaseService.saveTask(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    return DatabaseService.deleteTask(id);
  }
}
