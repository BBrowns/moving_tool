import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';
import 'package:moving_tool_flutter/features/projects/domain/repositories/projects_repository.dart';
import 'package:moving_tool_flutter/data/services/database_service.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  @override
  List<Project> getAllProjects() {
    return DatabaseService.getAllProjects();
  }

  @override
  Project? getProject(String id) {
    // DatabaseService doesn't have explicit getById, but getProject() gets active, or we can find in list
    // Or we can rely on getAllProjects().firstWhere... 
    // Actually DatabaseService.getAllProjects() returns all. Hive box.get(id) works.
    // DatabaseService implementation details are static.
    // Let's implement using what DatabaseService exposes or expand DatabaseService if needed.
    // DatabaseService.getProject() gets active.
    // We can filter from getAllProjects().
    try {
      return getAllProjects().firstWhere((p) => p.id == id);
    } catch (e) {
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
