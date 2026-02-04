import 'package:flutter/foundation.dart';
import 'package:moving_tool_flutter/core/error/exceptions.dart';
import 'package:moving_tool_flutter/data/services/database_service.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';
import 'package:moving_tool_flutter/features/projects/domain/repositories/projects_repository.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  @override
  List<Project> getAllProjects() {
    try {
      return DatabaseService.getAllProjects();
    } catch (e) {
      debugPrint('Error getting projects: $e');
      throw FetchFailure('Failed to load projects', e);
    }
  }

  @override
  Project? getProject(String id) {
    try {
      return getAllProjects().firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Project? getActiveProject() {
    try {
      return DatabaseService.getProject();
    } catch (e) {
      debugPrint('Error getting active project: $e');
      throw FetchFailure('Failed to load active project', e);
    }
  }

  @override
  String? getActiveProjectId() {
    try {
      return DatabaseService.getActiveProjectId();
    } catch (e) {
      debugPrint('Error getting active project ID: $e');
      return null;
    }
  }

  @override
  Future<void> saveProject(Project project) async {
    try {
      await DatabaseService.saveProject(project);
    } catch (e) {
      debugPrint('Error saving project: $e');
      throw SaveFailure('Failed to save project', e);
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    try {
      await DatabaseService.deleteProject(id);
    } catch (e) {
      debugPrint('Error deleting project: $e');
      throw DeleteFailure('Failed to delete project', e);
    }
  }

  @override
  Future<void> setActiveProject(String id) async {
    try {
      await DatabaseService.setActiveProject(id);
    } catch (e) {
      debugPrint('Error setting active project: $e');
      throw SaveFailure('Failed to set active project', e);
    }
  }
}
