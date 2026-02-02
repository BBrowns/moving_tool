import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';

abstract class ProjectsRepository {
  List<Project> getAllProjects();
  Project? getProject(String id);
  Project? getActiveProject();
  String? getActiveProjectId();
  Future<void> saveProject(Project project);
  Future<void> deleteProject(String id);
  Future<void> setActiveProject(String id);
}
