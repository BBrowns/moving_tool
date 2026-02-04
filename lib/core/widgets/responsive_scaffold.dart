// Responsive Scaffold
// Automatically manages FloatingActionButton vs AppBar Action based on screen size
import 'package:flutter/material.dart';
import 'package:moving_tool_flutter/core/widgets/responsive_wrapper.dart';

class ResponsiveScaffold extends StatelessWidget {

  const ResponsiveScaffold({
    required this.title, required this.body, super.key,
    this.actions,
    this.floatingActionButton,
    this.fabLabel,
    this.fabIcon,
    this.onFabPressed,
    this.fabHeroTag,
  });
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final String? fabLabel;
  final IconData? fabIcon;
  final VoidCallback? onFabPressed;
  final Object? fabHeroTag;

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
      const SizedBox(width: 8),
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


