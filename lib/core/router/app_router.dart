// App Router - Navigation with GoRouter
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/data/providers/providers.dart';
import 'package:moving_tool_flutter/features/dashboard/dashboard_screen.dart';
import 'package:moving_tool_flutter/features/expenses/expenses_screen.dart';
import 'package:moving_tool_flutter/features/onboarding/onboarding_screen.dart';
import 'package:moving_tool_flutter/features/packing/packing_screen.dart';
import 'package:moving_tool_flutter/features/playbook/playbook_screen.dart';
import 'package:moving_tool_flutter/features/projects/projects_screen.dart';
// ... (rest of imports)

import 'package:moving_tool_flutter/features/settings/settings_screen.dart';
import 'package:moving_tool_flutter/features/shell/app_shell.dart';
import 'package:moving_tool_flutter/features/shopping/shopping_screen.dart';
import 'package:moving_tool_flutter/features/tasks/tasks_screen.dart';
import 'package:moving_tool_flutter/features/transport/presentation/screens/transport_screen.dart';
import 'package:moving_tool_flutter/features/assets/presentation/screens/asset_screen.dart';
import 'package:moving_tool_flutter/features/admin_vault/presentation/screens/admin_vault_screen.dart';
import 'package:moving_tool_flutter/features/ar_studio/presentation/screens/ar_studio_screen.dart';
import 'package:moving_tool_flutter/features/ar_studio/presentation/screens/ar_camera_screen.dart';
import 'package:moving_tool_flutter/features/receipt_scanner/presentation/screens/receipt_scanner_screen.dart';
import 'package:moving_tool_flutter/features/transport/presentation/screens/transport_matcher_screen.dart';

/// Custom page builder that provides adaptive transitions:
/// - Desktop/Web: No transition (instant switch) for main tabs
/// - Mobile: Fade transition for tab navigation
Page<void> _buildAdaptivePage({
  required Widget child,
  required GoRouterState state,
  bool isMainTab = false,
}) {
  // 1. Test Mode or Desktop -> No Transition
  final bool isDesktop =
      kIsWeb ||
      (defaultTargetPlatform != TargetPlatform.iOS &&
          defaultTargetPlatform != TargetPlatform.android);

  if (AppTheme.isTestMode || isDesktop) {
    return NoTransitionPage(key: state.pageKey, child: child);
  }

  // 2. Main Tabs -> Custom Fade Transition
  // 2. Main Tabs -> Directional Slide or Fade
  // 2. Main Tabs -> No Transition (Handled by AppShell for sliding effect)
  if (isMainTab) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: Duration.zero, // Instant, shell handles animation
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }

  // 3. Detail Screens (Mobile) -> Native Platform Transition
  // This enables native "Swipe Back" gesture on iOS
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return CupertinoPage(key: state.pageKey, child: child);
  }

  return MaterialPage(key: state.pageKey, child: child);
}

final routerProvider = Provider<GoRouter>((ref) {
  final project = ref.watch(projectProvider);

  return GoRouter(
    initialLocation: project == null ? '/onboarding' : '/dashboard',
    routes: [
      // Onboarding - uses platform-native transition
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _buildAdaptivePage(
          child: const OnboardingScreen(),
          state: state,
          isMainTab: false,
        ),
      ),
      // Projects list - standalone screen
      GoRoute(
        path: '/projects',
        pageBuilder: (context, state) => _buildAdaptivePage(
          child: const ProjectsScreen(),
          state: state,
          isMainTab: false,
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _buildAdaptivePage(
          child: const SettingsScreen(),
          state: state,
          isMainTab: false,
        ),
      ),

      // Main app shell with navigation
      // Main app shell with navigation (Stateful for PageView swipe)
      StatefulShellRoute(
        navigatorContainerBuilder: (context, navigationShell, children) {
          return AppShell(navigationShell: navigationShell, children: children);
        },
        builder: (context, state, navigationShell) {
          return navigationShell;
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                pageBuilder: (context, state) => _buildAdaptivePage(
                  child: const DashboardScreen(),
                  state: state,
                  isMainTab: true,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                pageBuilder: (context, state) => _buildAdaptivePage(
                  child: const TasksScreen(),
                  state: state,
                  isMainTab: true,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/packing',
                pageBuilder: (context, state) => _buildAdaptivePage(
                  child: const PackingScreen(),
                  state: state,
                  isMainTab: true,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/shopping',
                pageBuilder: (context, state) => _buildAdaptivePage(
                  child: const ShoppingScreen(),
                  state: state,
                  isMainTab: true,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/expenses',
                pageBuilder: (context, state) => _buildAdaptivePage(
                  child: const ExpensesScreen(),
                  state: state,
                  isMainTab: true,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transport',
                pageBuilder: (context, state) => _buildAdaptivePage(
                  child: const TransportScreen(),
                  state: state,
                  isMainTab: true,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/playbook',
                pageBuilder: (context, state) => _buildAdaptivePage(
                  child: const PlaybookScreen(),
                  state: state,
                  isMainTab: true,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/assets',
                pageBuilder: (context, state) => _buildAdaptivePage(
                  child: const AssetScreen(),
                  state: state,
                  isMainTab: true,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin-vault',
                pageBuilder: (context, state) => _buildAdaptivePage(
                  child: const AdminVaultScreen(),
                  state: state,
                  isMainTab: true,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ar-studio',
                pageBuilder: (context, state) => _buildAdaptivePage(
                  child: const ARStudioScreen(),
                  state: state,
                  isMainTab: true,
                ),
                routes: [
                  GoRoute(
                    path: 'camera',
                    pageBuilder: (context, state) {
                      final modeStr =
                          state.uri.queryParameters['mode'] ?? 'roomScan';
                      final mode = modeStr == 'furniturePlacement'
                          ? ARMode.furniturePlacement
                          : ARMode.roomScan;

                      return _buildAdaptivePage(
                        child: ARCameraScreen(mode: mode),
                        state: state,
                        isMainTab: false,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/receipt-scanner',
                pageBuilder: (context, state) => _buildAdaptivePage(
                  child: const ReceiptScannerScreen(),
                  state: state,
                  isMainTab: false,
                ),
              ),
            ],
          ),
        ],
      ),

      // Standalone Tools
      GoRoute(
        path: '/transport-matcher',
        pageBuilder: (context, state) => _buildAdaptivePage(
          child: const TransportMatcherScreen(),
          state: state,
          isMainTab: false,
        ),
      ),
    ],
    redirect: (context, state) {
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isProjects = state.matchedLocation == '/projects';

      if (project == null && !isOnboarding && !isProjects) {
        return '/onboarding';
      }

      return null;
    },
  );
});
