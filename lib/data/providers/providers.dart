// Riverpod Providers - State management for the app
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:moving_tool_flutter/core/models/models.dart';
import 'package:moving_tool_flutter/data/services/database_service.dart';
export 'package:moving_tool_flutter/features/packing/presentation/providers/packing_providers.dart';
export 'package:moving_tool_flutter/features/shopping/presentation/providers/shopping_providers.dart';
export 'package:moving_tool_flutter/features/playbook/presentation/providers/playbook_providers.dart';

export 'package:moving_tool_flutter/features/tasks/presentation/providers/task_providers.dart';

export 'package:moving_tool_flutter/features/expenses/presentation/providers/expense_providers.dart';
export 'package:moving_tool_flutter/features/projects/presentation/providers/project_providers.dart';

const _uuid = Uuid();

// ============================================================================
// Theme Provider
// ============================================================================
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void set(ThemeMode mode) => state = mode;
}
final themeModeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
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
