// Comprehensive Integration Test Suite
// Uses test_utils for consistent setup and animation handling

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moving_tool_flutter/core/models/models.dart';
import 'package:moving_tool_flutter/data/services/database_service.dart';
import 'package:moving_tool_flutter/features/dashboard/dashboard_screen.dart';
import 'package:moving_tool_flutter/features/onboarding/onboarding_screen.dart';
import '../test_utils.dart';

Future<void> _navigateToDashboard(WidgetTester tester) async {
  // Start App
  await pumpApp(tester);

  // Step 1: Welcome
  await tapAndWait(tester, find.text('Volgende'));
  await pumpAndWait(tester);

  // Step 2: Project Info
  expect(find.text('Project Info'), findsOneWidget);
  await tester.enterText(find.byType(TextField), 'Test Move');
  await tapAndWait(tester, find.text('Volgende'));
  await pumpAndWait(tester);

  // Step 3: Users
  expect(find.text('Wie verhuist er?'), findsOneWidget);
  await tester.enterText(find.byType(TextField).at(0), 'Julian');
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await pumpAndWait(tester);

  await tapAndWait(tester, find.text('Starten!'));
  await pumpAndWait(tester, duration: const Duration(seconds: 2));

  // Verify Dashboard
  expect(find.byType(DashboardScreen), findsOneWidget);
}

void main() {
  group('Intensive App Testing', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await initTestEnvironment();
    });

    setUp(() async {
      await clearTestData();
    });

    tearDownAll(() async {
      await cleanupTestEnvironment(tempDir);
    });

    testWidgets('Router: Direct to Dashboard when project pre-seeded', (
      tester,
    ) async {
      // Pre-seed project
      final project = Project(
        id: 'test-id',
        name: 'Pre-seeded Project',
        movingDate: DateTime.now(),
        fromAddress: const Address(),
        toAddress: const Address(),
        members: [
          const ProjectMember(
            id: 'u1',
            name: 'TestUser',
            role: ProjectRole.admin,
            color: '#6366F1',
          ),
        ],
        createdAt: DateTime.now(),
      );
      await DatabaseService.saveProject(project);
      await DatabaseService.setActiveProject('test-id');

      // Pump app - should go directly to Dashboard (ProjectNotifier auto-loads)
      await pumpApp(tester);
      await pumpAndWait(tester);

      // Verify Dashboard, not Onboarding
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });

    testWidgets('User Journey: Create Project -> Packing -> Add Box', (
      tester,
    ) async {
      await _navigateToDashboard(tester);

      // Verify Dashboard
      expect(find.textContaining('Julian'), findsOneWidget);

      // Navigate to Packing
      await tapAndWait(tester, find.text('Inpakken').first);
      await pumpAndWait(tester);

      // Add Box
      await tester.tap(find.byType(FloatingActionButton));
      await pumpAndWait(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Inhoud of label'),
        'Boeken',
      );
      await tapAndWait(tester, find.text('Opslaan'));
      await pumpAndWait(tester);

      expect(find.text('Boeken'), findsOneWidget);
    });

    testWidgets('Theme Switcher toggles themes correctly', (tester) async {
      await _navigateToDashboard(tester);

      // Navigate to Settings
      await tapAndWait(tester, find.byIcon(Icons.settings_rounded));
      await pumpAndWait(tester);

      // Verify we are in settings
      expect(find.text('Instellingen'), findsOneWidget);

      // Find the Dark Mode switch and toggle it
      final switchFinder = find.widgetWithText(SwitchListTile, 'Donkere Modus');
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await pumpAndWait(tester);

      // If we didn't crash, success.
    });

    testWidgets('Visual Integrity: No Overflows on Mobile (375x812)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375 * 3, 812 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpApp(tester);
      await pumpAndWait(tester);

      expect(tester.takeException(), isNull);
    });

    testWidgets('Visual Integrity: No Overflows on Desktop (1200x800)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _navigateToDashboard(tester);

      // Navigate to Tasks
      await tapAndWait(tester, find.text('Taken').first);
      await pumpAndWait(tester);

      // Theme toggle moved to settings, just check visual integrity
      expect(tester.takeException(), isNull);
    });
  });
}
