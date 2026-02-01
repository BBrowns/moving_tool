import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'data/services/database_service.dart';
import 'data/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  await DatabaseService.initialize();
  
  runApp(const ProviderScope(child: MovingToolApp()));
}

class MovingToolApp extends ConsumerStatefulWidget {
  const MovingToolApp({super.key});

  @override
  ConsumerState<MovingToolApp> createState() => _MovingToolAppState();
}

class _MovingToolAppState extends ConsumerState<MovingToolApp> {
  @override
  void initState() {
    super.initState();
    // Load all data on startup
    Future.microtask(() {
      ref.read(projectProvider.notifier).load();
      ref.read(taskProvider.notifier).load();
      ref.read(roomProvider.notifier).load();
      ref.read(boxProvider.notifier).load();
      ref.read(boxItemProvider.notifier).load();
      ref.read(shoppingProvider.notifier).load();
      ref.read(expenseProvider.notifier).load();
      ref.read(journalProvider.notifier).load();
      ref.read(notesProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Verhuistool',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark theme
      routerConfig: router,
    );
  }
}
