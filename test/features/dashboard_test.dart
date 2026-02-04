// Dashboard Screen Tests - Bento Grid Layout
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moving_tool_flutter/core/models/models.dart';
import 'package:moving_tool_flutter/data/providers/providers.dart';
import 'package:moving_tool_flutter/features/dashboard/dashboard_screen.dart';
import 'package:moving_tool_flutter/features/projects/domain/repositories/projects_repository.dart';
import 'package:moving_tool_flutter/features/projects/presentation/providers/project_providers.dart';

class TestProjectNotifier extends ProjectNotifier {
  TestProjectNotifier(this._initialProject);
  final Project? _initialProject;

  @override
  Project? build() {
    repository = ref.watch(projectsRepositoryProvider);
    return _initialProject;
  }
}

// Mock project for testing
final mockProject = Project(
  id: 'test-project-id',
  name: 'Test Verhuizing',
  movingDate: DateTime.now().add(const Duration(days: 30)),
  fromAddress: const Address(),
  toAddress: const Address(),
  members: [
    const ProjectMember(
      id: 'user-1',
      name: 'Test User',
      role: ProjectRole.admin,
      color: '#6366F1',
    ),
  ],
  createdAt: DateTime.now(),
);

// Mock Repository
class MockProjectsRepository implements ProjectsRepository {
  @override
  List<Project> getAllProjects() => [mockProject];
  @override
  Project? getProject(String id) => mockProject;
  @override
  Project? getActiveProject() => mockProject;
  @override
  String? getActiveProjectId() => mockProject.id;
  @override
  Future<void> saveProject(Project project) async {}
  @override
  Future<void> deleteProject(String id) async {}
  @override
  Future<void> setActiveProject(String id) async {}
}

void main() {
  group('DashboardScreen', () {
    testWidgets('shows loading indicator when project is null', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectProvider.overrideWith(() => TestProjectNotifier(null)),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const DashboardScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders dashboard headers when project exists', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectsRepositoryProvider.overrideWithValue(
              MockProjectsRepository(),
            ),
            projectProvider.overrideWith(
              () => TestProjectNotifier(mockProject),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const DashboardScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show the greeting
      expect(find.textContaining('Hallo Test User!'), findsOneWidget);

      // Should show days until move
      expect(find.textContaining('dagen tot de grote dag'), findsOneWidget);
    });

    testWidgets('displays bento grid cards with correct info', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectsRepositoryProvider.overrideWithValue(
              MockProjectsRepository(),
            ),
            projectProvider.overrideWith(
              () => TestProjectNotifier(mockProject),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const DashboardScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Bento Cards Titles
      expect(find.text('Taken'), findsOneWidget);
      expect(find.text('Inpakken'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Budget'), findsOneWidget);

      // Verify Action Labels (which imply the cards are fully rendered)
      // Verify Subtitles
      expect(find.text('Afgerond'), findsOneWidget);
      expect(find.text('Dozen Klaar'), findsOneWidget);
      expect(find.text('Gekocht'), findsOneWidget);
      expect(find.text('Uitgegeven'), findsOneWidget);
    });

    testWidgets('tapping a bento card navigates to correct route', (
      WidgetTester tester,
    ) async {
      String? lastRoute;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectProvider.overrideWith(
              () => TestProjectNotifier(mockProject),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const DashboardScreen(),
                ),
                GoRoute(
                  path: '/tasks',
                  builder: (context, state) {
                    lastRoute = '/tasks';
                    return const Scaffold(body: Text('Tasks Screen'));
                  },
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the "Taken" card (we tap the text "Taken" instead of "Nieuwe taak")
      await tester.tap(find.text('Taken'));
      await tester.pumpAndSettle();

      expect(lastRoute, '/tasks');
    });
  });
}
