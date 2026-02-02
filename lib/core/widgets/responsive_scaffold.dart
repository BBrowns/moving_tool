// Responsive Scaffold
// Automatically manages FloatingActionButton vs AppBar Action based on screen size
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/providers.dart';
import '../widgets/responsive_wrapper.dart';

class ResponsiveScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final String? fabLabel;
  final IconData? fabIcon;
  final VoidCallback? onFabPressed;
  final Object? fabHeroTag;

  const ResponsiveScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.fabLabel,
    this.fabIcon,
    this.onFabPressed,
    this.fabHeroTag,
  });

  @override
  Widget build(BuildContext context) {
    // If mobile: show FAB in corner
    // If desktop: show Action Button in AppBar (if onFabPressed provided)
    
    final isDesktop = context.isDesktop;
    
    final effectiveActions = [
      if (isDesktop && onFabPressed != null && fabLabel != null)
        FilledButton.icon(
          onPressed: onFabPressed,
          icon: Icon(fabIcon ?? Icons.add, size: 18),
          label: Text(fabLabel!),
        )
      else if (isDesktop && onFabPressed != null)
        IconButton(
          onPressed: onFabPressed,
          icon: Icon(fabIcon ?? Icons.add),
          tooltip: fabLabel,
        ),
      const SizedBox(width: 8),
      ...?actions,
      const SizedBox(width: 8),
      const ThemeSwitcherButton(),
      const SizedBox(width: 8),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: effectiveActions,
      ),
      body: body,
      floatingActionButton: !isDesktop && onFabPressed != null
          ? floatingActionButton ?? FloatingActionButton.extended(
              onPressed: onFabPressed,
              icon: Icon(fabIcon ?? Icons.add),
              label: Text(fabLabel ?? 'Add'),
              heroTag: fabHeroTag,
            )
          : null,
    );
  }
}

class ThemeSwitcherButton extends ConsumerWidget {
  const ThemeSwitcherButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    IconData icon = Icons.brightness_auto;
    String tooltip = 'System Theme';

    switch (themeMode) {
      case ThemeMode.system:
        icon = Icons.brightness_auto;
        tooltip = 'System Theme';
        break;
      case ThemeMode.light:
        icon = Icons.wb_sunny;
        tooltip = 'Light Theme';
        break;
      case ThemeMode.dark:
        icon = Icons.nightlight_round;
        tooltip = 'Dark Theme';
        break;
    }

    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: () {
        // Cycle: System -> Light -> Dark -> System
        final newMode = switch (themeMode) {
          ThemeMode.system => ThemeMode.light,
          ThemeMode.light => ThemeMode.dark,
          ThemeMode.dark => ThemeMode.system,
        };
        ref.read(themeModeProvider.notifier).set(newMode);
      },
    );
  }
}
