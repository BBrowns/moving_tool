import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moving_tool_flutter/features/shell/app_shell.dart';
import 'package:moving_tool_flutter/core/widgets/responsive_wrapper.dart'; // Ensure Breakpoints are available if needed or just use surface size

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
                  Scaffold(body: Text('Dashboard')),
                  Scaffold(body: Text('Taken')),
                  Scaffold(body: Text('Inpakken')),
                  Scaffold(body: Text('Shopping')),
                  Scaffold(body: Text('Uitgaven')),
                  Scaffold(body: Text('Playbook')),
                ],
              );
            },
            branches: [
              StatefulShellBranch(routes: [GoRoute(path: '/dashboard', builder: (_, __) => const SizedBox())]),
              StatefulShellBranch(routes: [GoRoute(path: '/tasks', builder: (_, __) => const SizedBox())]),
              StatefulShellBranch(routes: [GoRoute(path: '/packing', builder: (_, __) => const SizedBox())]),
              StatefulShellBranch(routes: [GoRoute(path: '/shopping', builder: (_, __) => const SizedBox())]),
              StatefulShellBranch(routes: [GoRoute(path: '/expenses', builder: (_, __) => const SizedBox())]),
              StatefulShellBranch(routes: [GoRoute(path: '/playbook', builder: (_, __) => const SizedBox())]),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('Displays NavigationBar on Mobile (small screen)', (WidgetTester tester) async {
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

    testWidgets('Displays NavigationRail on Desktop (large screen)', (WidgetTester tester) async {
      // Set surface size to Desktop (1920x1080)
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpAppShell(tester);

      // Verify Side Navigation Rail is present
      expect(find.byType(NavigationRail), findsOneWidget);
      // Verify Bottom Navigation Bar is absent
      expect(find.byType(NavigationBar), findsNothing);
    });
  });
}
