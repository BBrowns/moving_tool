import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';
import 'package:moving_tool_flutter/features/projects/domain/repositories/projects_repository.dart';
import 'package:moving_tool_flutter/features/projects/data/repositories/projects_repository_impl.dart';

const _uuid = Uuid();

final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  return ProjectsRepositoryImpl();
});

// ============================================================================
// Projects Notifier (List of all projects)
// ============================================================================

class ProjectsNotifier extends Notifier<List<Project>> {
  late final ProjectsRepository repository;

  @override
  List<Project> build() {
    repository = ref.watch(projectsRepositoryProvider);
    return [];
  }

  void load() {
    state = repository.getAllProjects();
  }

  Future<void> add(Project project) async {
    await repository.saveProject(project);
    state = [...state, project];
  }

  Future<void> delete(String projectId) async {
    await repository.deleteProject(projectId);
    state = state.where((p) => p.id != projectId).toList();
  }
}

final projectsProvider = NotifierProvider<ProjectsNotifier, List<Project>>(ProjectsNotifier.new);


// ============================================================================
// Single Active Project Notifier
// ============================================================================

class ProjectNotifier extends Notifier<Project?> {
  late final ProjectsRepository repository;

  @override
  Project? build() {
    repository = ref.watch(projectsRepositoryProvider);
    return repository.getActiveProject(); // Auto-load active project
  }

  void load() {
    state = repository.getActiveProject();
  }

  Future<void> save(Project project) async {
    await repository.saveProject(project);
    state = project;
  }

  Future<void> setActive(String projectId) async {
    await repository.setActiveProject(projectId);
    load();
  }

  Future<void> addUser(String name, String color) async {
    if (state == null) return;
    final user = User(id: _uuid.v4(), name: name, color: color);
    final updated = state!.copyWith(users: [...state!.users, user]);
    await save(updated);
  }

  Future<void> removeUser(String userId) async {
    if (state == null) return;
    final updated = state!.copyWith(
      users: state!.users.where((u) => u.id != userId).toList(),
    );
    await save(updated);
  }
}

final projectProvider = NotifierProvider<ProjectNotifier, Project?>(ProjectNotifier.new);
