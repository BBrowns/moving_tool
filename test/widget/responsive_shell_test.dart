import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moving_tool_flutter/features/shell/app_shell.dart';

void main() {
  group('AppShell Responsive Tests', () {
    // Helper to pump AppShell via GoRouter
    Future<void> pumpAppShell(WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/dashboard',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return AppShell(
                navigationShell: navigationShell,
                children: const [
                  Scaffold(body: Text('Dashboard Body')),
                  Scaffold(body: Text('Taken Body')),
                  Scaffold(body: Text('Inpakken Body')),
                  Scaffold(body: Text('Shopping Body')),
                  Scaffold(body: Text('Uitgaven Body')),
                  Scaffold(body: Text('Playbook Body')),
                ],
              );
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/dashboard',
                    builder: (_, _) => const SizedBox(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(path: '/tasks', builder: (_, _) => const SizedBox()),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/packing',
                    builder: (_, _) => const SizedBox(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/shopping',
                    builder: (_, _) => const SizedBox(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/expenses',
                    builder: (_, _) => const SizedBox(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/playbook',
                    builder: (_, _) => const SizedBox(),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
    }

    testWidgets('Displays NavigationBar on Mobile (small screen)', (
      WidgetTester tester,
    ) async {
      // Set surface size to Mobile Portrait
      tester.view.physicalSize = const Size(400 * 3, 800 * 3); // ~iPhone
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpAppShell(tester);

      // Verify Bottom Navigation Bar is present
      expect(find.byType(NavigationBar), findsOneWidget);
      // Verify Rail is absent
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('Displays NavigationRail on Desktop (large screen)', (
      WidgetTester tester,
    ) async {
      // Set surface size to Desktop (1920x1080)
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpAppShell(tester);

      // Verify Side Navigation Rail is present
      final railFinder = find.byType(NavigationRail);
      expect(railFinder, findsOneWidget);
      // Verify Bottom Navigation Bar is absent
      expect(find.byType(NavigationBar), findsNothing);

      // Verify Rail properties: Extended (extended=true) and Labels hidden (type=none)
      // Note: Labels are shown because extended is true, overriding type=none
      final rail = tester.widget<NavigationRail>(railFinder);
      expect(
        rail.extended,
        isTrue,
        reason: 'Rail should be extended on Desktop',
      );
      expect(
        rail.labelType,
        NavigationRailLabelType.none,
        reason: 'LabelType is none (but ignored due to extended)',
      );
    });

    testWidgets('Displays compact NavigationRail on Tablet (medium screen)', (
      WidgetTester tester,
    ) async {
      // Set surface size to Tablet (iPad Pro 11-inch width ~834 logical)
      // Breakpoints: mobile < 600, tablet < 1200
      tester.view.physicalSize = const Size(900, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpAppShell(tester);

      // Verify Side Navigation Rail is present
      final railFinder = find.byType(NavigationRail);
      expect(railFinder, findsOneWidget);
      // Verify Bottom Navigation Bar is absent
      expect(find.byType(NavigationBar), findsNothing);

      // Verify Rail properties: Compact (extended=false) and Labels hidden (type=none)
      final rail = tester.widget<NavigationRail>(railFinder);
      expect(
        rail.extended,
        isFalse,
        reason: 'Rail should be compact on Tablet',
      );
      expect(
        rail.labelType,
        NavigationRailLabelType.none,
        reason: 'Labels should be hidden on Tablet due to labelType.none',
      );
    });
  });
}
