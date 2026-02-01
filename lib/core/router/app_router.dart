// App Router - Navigation with GoRouter
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moving_tool_flutter/data/providers/providers.dart';
import 'package:moving_tool_flutter/features/onboarding/onboarding_screen.dart';
import 'package:moving_tool_flutter/features/shell/app_shell.dart';
import 'package:moving_tool_flutter/features/dashboard/dashboard_screen.dart';
import 'package:moving_tool_flutter/features/tasks/tasks_screen.dart';
import 'package:moving_tool_flutter/features/packing/packing_screen.dart';
import 'package:moving_tool_flutter/features/shopping/shopping_screen.dart';
import 'package:moving_tool_flutter/features/costs/costs_screen.dart';
import 'package:moving_tool_flutter/features/playbook/playbook_screen.dart';
import 'package:moving_tool_flutter/features/settings/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final project = ref.watch(projectProvider);

  return GoRouter(
    initialLocation: project == null ? '/onboarding' : '/dashboard',
    routes: [
      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Main app shell with navigation
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TasksScreen(),
          ),
          GoRoute(
            path: '/packing',
            builder: (context, state) => const PackingScreen(),
          ),
          GoRoute(
            path: '/shopping',
            builder: (context, state) => const ShoppingScreen(),
          ),
          GoRoute(
            path: '/costs',
            builder: (context, state) => const CostsScreen(),
          ),
          GoRoute(
            path: '/playbook',
            builder: (context, state) => const PlaybookScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isOnboarding = state.matchedLocation == '/onboarding';
      
      if (project == null && !isOnboarding) {
        return '/onboarding';
      }
      
      if (project != null && isOnboarding) {
        return '/dashboard';
      }
      
      return null;
    },
  );
});
