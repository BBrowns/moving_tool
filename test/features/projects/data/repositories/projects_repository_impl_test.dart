import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:moving_tool_flutter/features/projects/data/repositories/projects_repository_impl.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';

import 'projects_repository_impl_test_mocks.mocks.dart';

void main() {
  late ProjectsRepositoryImpl repository;
  late MockProjectsLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockProjectsLocalDataSource();
    repository = ProjectsRepositoryImpl(mockDataSource);
  });

  final tProject = Project(
    id: '1',
    name: 'Test Project',
    movingDate: DateTime.now(),
    fromAddress: const Address(),
    toAddress: const Address(),
    members: const [],
    createdAt: DateTime.now(),
  );

  test('getAllProjects returns data from dataSource', () {
    when(mockDataSource.getAllProjects()).thenReturn([tProject]);
    final result = repository.getAllProjects();
    expect(result, [tProject]);
    verify(mockDataSource.getAllProjects());
  });

  test('saveProject calls dataSource.saveProject', () async {
    when(mockDataSource.saveProject(tProject)).thenAnswer((_) async {});
    await repository.saveProject(tProject);
    verify(mockDataSource.saveProject(tProject));
  });

  test('deleteProject calls dataSource.deleteProject', () async {
    when(mockDataSource.deleteProject('1')).thenAnswer((_) async {});
    await repository.deleteProject('1');
    verify(mockDataSource.deleteProject('1'));
  });

  test('getActiveProject calls dataSource.getActiveProject', () {
    when(mockDataSource.getActiveProject()).thenReturn(tProject);
    final result = repository.getActiveProject();
    expect(result, tProject);
    verify(mockDataSource.getActiveProject());
  });

  test('setActiveProject calls dataSource.setActiveProject', () async {
    when(mockDataSource.setActiveProject('1')).thenAnswer((_) async {});
    await repository.setActiveProject('1');
    verify(mockDataSource.setActiveProject('1'));
  });
}
