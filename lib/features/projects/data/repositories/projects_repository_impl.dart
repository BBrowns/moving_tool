import 'package:flutter/foundation.dart';
import 'package:moving_tool_flutter/core/error/exceptions.dart';
import 'package:moving_tool_flutter/features/projects/data/datasources/projects_local_data_source.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';
import 'package:moving_tool_flutter/features/projects/domain/repositories/projects_repository.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectsLocalDataSource dataSource;

  ProjectsRepositoryImpl(this.dataSource);

  @override
  List<Project> getAllProjects() {
    try {
      return dataSource.getAllProjects();
    } catch (e) {
      debugPrint('Error getting projects: $e');
      throw FetchFailure('Failed to load projects', e);
    }
  }

  @override
  Project? getProject(String id) {
    try {
      return dataSource.getProject(id);
    } catch (e) {
      return null;
    }
  }

  @override
  Project? getActiveProject() {
    try {
      return dataSource.getActiveProject();
    } catch (e) {
      debugPrint('Error getting active project: $e');
      throw FetchFailure('Failed to load active project', e);
    }
  }

  @override
  String? getActiveProjectId() {
    try {
      return dataSource.getActiveProjectId();
    } catch (e) {
      debugPrint('Error getting active project ID: $e');
      return null;
    }
  }

  @override
  Future<void> saveProject(Project project) async {
    try {
      await dataSource.saveProject(project);
    } catch (e) {
      debugPrint('Error saving project: $e');
      throw SaveFailure('Failed to save project', e);
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    try {
      await dataSource.deleteProject(id);
    } catch (e) {
      debugPrint('Error deleting project: $e');
      throw DeleteFailure('Failed to delete project', e);
    }
  }

  @override
  Future<void> setActiveProject(String id) async {
    try {
      await dataSource.setActiveProject(id);
    } catch (e) {
      debugPrint('Error setting active project: $e');
      throw SaveFailure('Failed to set active project', e);
    }
  }
}
