// Test utilities for consistent test setup
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/data/services/database_service.dart';
import 'package:moving_tool_flutter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global test setup - call in setUpAll
Future<Directory> initTestEnvironment() async {
  SharedPreferences.setMockInitialValues({});
  AppTheme.isTestMode = true; // Disable animations
  GoogleFonts.config.allowRuntimeFetching = false; // Disable font fetching
  final tempDir = await Directory.systemTemp.createTemp();
  await DatabaseService.initialize(isTest: true, testPath: tempDir.path);
  return tempDir;
}

/// Clean up test environment - call in tearDownAll
Future<void> cleanupTestEnvironment(Directory tempDir) async {
  await Hive.close();
  if (await tempDir.exists()) {
    await tempDir.delete(recursive: true);
  }
  AppTheme.isTestMode = false;
}

/// Clear data between tests - call in setUp
Future<void> clearTestData() async {
  SharedPreferences.setMockInitialValues({});
  await DatabaseService.clearAll();
}

/// Pump app and wait for animations to complete
/// Uses fixed duration instead of pumpAndSettle to handle flutter_animate
Future<void> pumpApp(WidgetTester tester, {Widget? child}) async {
  await tester.pumpWidget(
    ProviderScope(child: child ?? const MovingToolApp()),
  );
  await tester.pump(const Duration(milliseconds: 500));
}

/// Pump and wait for async operations + animations
Future<void> pumpAndWait(WidgetTester tester, {Duration? duration}) async {
  await tester.pump(duration ?? const Duration(seconds: 1));
}

/// Tap and wait for result
Future<void> tapAndWait(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 500));
}
