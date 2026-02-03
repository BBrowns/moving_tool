import 'package:flutter/foundation.dart';
import 'package:moving_tool_flutter/core/error/exceptions.dart';
import 'package:moving_tool_flutter/data/services/database_service.dart';
import 'package:moving_tool_flutter/features/tasks/domain/entities/task.dart';
import 'package:moving_tool_flutter/features/tasks/domain/repositories/tasks_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  @override
  Future<List<Task>> getTasks() async {
    try {
      return DatabaseService.getAllTasks();
    } catch (e) {
      debugPrint('Error getting tasks: $e');
      throw FetchFailure('Failed to load tasks', e);
    }
  }

  @override
  Future<void> saveTask(Task task) async {
    try {
      await DatabaseService.saveTask(task);
    } catch (e) {
      debugPrint('Error saving task: $e');
      throw SaveFailure('Failed to save task', e);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await DatabaseService.deleteTask(id);
    } catch (e) {
      debugPrint('Error deleting task: $e');
      throw DeleteFailure('Failed to delete task', e);
    }
  }
}
