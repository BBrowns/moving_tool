import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moving_tool_flutter/core/models/models.dart';
import 'package:moving_tool_flutter/data/services/database_service.dart';
import 'package:moving_tool_flutter/features/projects/presentation/providers/project_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ProjectNotifier Integration with Hive', () {
    late Directory tempDir;
    late ProviderContainer container;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      tempDir = await Directory.systemTemp.createTemp();
      await DatabaseService.initialize(isTest: true, testPath: tempDir.path);
    });

    setUp(() async {
      await DatabaseService.clearAll();
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    tearDownAll(() async {
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('save() should persist project to Hive and update state', () async {
      final project = Project(
        id: 'p1',
        name: 'Test Project',
        movingDate: DateTime.now(),
        fromAddress: const Address(),
        toAddress: const Address(),
        members: [],
        createdAt: DateTime.now(),
      );

      final notifier = container.read(projectProvider.notifier);
      await notifier.save(project);

      // Verify State
      expect(container.read(projectProvider), project);

      // Verify Hive
      final all = DatabaseService.getAllProjects();
      final fromDb = all.firstWhere((p) => p.id == 'p1');
      expect(fromDb.name, 'Test Project');
      // save() auto-sets active if first.

      final activeId = DatabaseService.getActiveProjectId();
      expect(activeId, 'p1');

      final activeProject = DatabaseService.getProject();
      expect(activeProject?.id, 'p1');
      expect(activeProject?.name, 'Test Project');
    });

    test('setActive() should switch projects and update state', () async {
      final p1 = Project(
        id: 'p1',
        name: 'Project 1',
        movingDate: DateTime.now(),
        fromAddress: const Address(),
        toAddress: const Address(),
        members: [],
        createdAt: DateTime.now(),
      );
      final p2 = Project(
        id: 'p2',
        name: 'Project 2',
        movingDate: DateTime.now(),
        fromAddress: const Address(),
        toAddress: const Address(),
        members: [],
        createdAt: DateTime.now(),
      );

      final notifier = container.read(projectProvider.notifier);
      await notifier.save(p1);
      await notifier.save(
        p2,
      ); // p1 was active. p2 saved. p1 remains active? Or p2 becomes active?
      // Logic: "if (getActiveProjectId() == null) { setActiveProject }".
      // So p1 set active. p2 saved but not active.

      var current = container.read(projectProvider);
      expect(current?.id, 'p2'); // save() updates state ONLY?
      // ProjectNotifier.save code: "state = project".
      // So state IS p2.
      // But Active ID in DB is p1.
      expect(DatabaseService.getActiveProjectId(), 'p1');

      // Now set Active p1
      await notifier.setActive('p1');
      current = container.read(projectProvider);
      expect(current?.id, 'p1');
      expect(DatabaseService.getActiveProjectId(), 'p1');

      // Now set Active p2
      await notifier.setActive('p2');
      current = container.read(projectProvider);
      expect(current?.id, 'p2');
      expect(DatabaseService.getActiveProjectId(), 'p2');
    });
  });
}
