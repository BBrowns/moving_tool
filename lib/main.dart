import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:moving_tool_flutter/core/router/app_router.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/data/providers/providers.dart';
import 'package:moving_tool_flutter/data/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize date formatting
    await initializeDateFormatting('nl_NL', null);

    // Initialize database
    await DatabaseService.initialize();
  } catch (e, stack) {
    debugPrint('Initialization failed: $e\n$stack');
    // On web, this might be a Hive/IndexedDB issue.
    // We continue to run the app so it doesn't just show a blank white screen,
    // though functionality might be broken.
  }

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
    // Skip loading in test mode (test_utils sets isTestMode)
    if (AppTheme.isTestMode) return;

    // Load all data on startup
    Future.microtask(() {
      ref.read(projectsProvider.notifier).load(); // Load all projects
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
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Verhuistool',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('nl'), // Dutch
      ],
      // locale: const Locale('nl'), // Force Dutch for testing if needed
      routerConfig: router,
    );
  }
}
