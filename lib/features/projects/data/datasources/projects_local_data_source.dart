import 'package:moving_tool_flutter/data/services/database_service.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';

abstract class ProjectsLocalDataSource {
  List<Project> getAllProjects();
  Project? getProject(String id);
  Project? getActiveProject();
  String? getActiveProjectId();
  Future<void> saveProject(Project project);
  Future<void> deleteProject(String id);
  Future<void> setActiveProject(String id);
}

class ProjectsLocalDataSourceImpl implements ProjectsLocalDataSource {
  @override
  List<Project> getAllProjects() {
    return DatabaseService.getAllProjects();
  }

  @override
  Project? getProject(String id) {
    // DatabaseService doesn't have a direct getProject(id) that returns nullable without active check.
    // But we can filter getAllProjects or assume DatabaseService.getProject() refers to active.
    // Let's implement efficiently if possible, or matches repo logic.
    try {
      return getAllProjects().firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Project? getActiveProject() {
    return DatabaseService.getProject();
  }

  @override
  String? getActiveProjectId() {
    return DatabaseService.getActiveProjectId();
  }

  @override
  Future<void> saveProject(Project project) async {
    await DatabaseService.saveProject(project);
  }

  @override
  Future<void> deleteProject(String id) async {
    await DatabaseService.deleteProject(id);
  }

  @override
  Future<void> setActiveProject(String id) async {
    await DatabaseService.setActiveProject(id);
  }
}
