import 'package:flutter/material.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:moving_tool_flutter/features/expenses/presentation/providers/expense_providers.dart';
export 'package:moving_tool_flutter/features/packing/presentation/providers/packing_providers.dart';
export 'package:moving_tool_flutter/features/playbook/presentation/providers/playbook_providers.dart';
export 'package:moving_tool_flutter/features/projects/presentation/providers/project_providers.dart';
export 'package:moving_tool_flutter/features/shopping/presentation/providers/shopping_providers.dart';
export 'package:moving_tool_flutter/features/tasks/presentation/providers/task_providers.dart';

// ============================================================================
// Theme Provider
// ============================================================================

part 'providers.g.dart';

// ============================================================================
// Theme Provider
// ============================================================================
@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() => ThemeMode.system;

  void set(ThemeMode mode) => state = mode;
}

// Backward compatibility
final themeModeProvider = themeProvider;
// MOVED TO: lib/features/tasks/presentation/providers/task_providers.dart
// ============================================================================

// ============================================================================
// Packing Providers (Room, PackingBox, BoxItem)
// MOVED TO: lib/features/packing/presentation/providers/packing_providers.dart
// ============================================================================

// ============================================================================
// Shopping Provider
// ============================================================================

// ============================================================================
// Shopping Provider
// MOVED TO: lib/features/shopping/presentation/providers/shopping_providers.dart
// ============================================================================

// ============================================================================
// Expense Provider
// ============================================================================

// ============================================================================
// Expense Provider
// MOVED TO: lib/features/expenses/presentation/providers/expense_providers.dart
// ============================================================================

// ============================================================================
// Playbook Providers
// MOVED TO: lib/features/playbook/presentation/providers/playbook_providers.dart
// ============================================================================
