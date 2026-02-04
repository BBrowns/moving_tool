import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moving_tool_flutter/features/projects/data/repositories/projects_repository_impl.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';
import 'package:moving_tool_flutter/features/projects/domain/repositories/projects_repository.dart';
import 'package:uuid/uuid.dart';

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

final projectsProvider = NotifierProvider<ProjectsNotifier, List<Project>>(
  ProjectsNotifier.new,
);

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

  Future<void> addMember(
    String name,
    ProjectRole role, {
    String color = '#6366F1',
  }) async {
    if (state == null) return;
    final member = ProjectMember(
      id: _uuid.v4(),
      name: name,
      role: role,
      color: color,
    );
    final updated = state!.copyWith(members: [...state!.members, member]);
    await save(updated);
  }

  Future<void> removeMember(String memberId) async {
    if (state == null) return;
    final updated = state!.copyWith(
      members: state!.members.where((m) => m.id != memberId).toList(),
    );
    await save(updated);
  }
}

final projectProvider = NotifierProvider<ProjectNotifier, Project?>(
  ProjectNotifier.new,
);
