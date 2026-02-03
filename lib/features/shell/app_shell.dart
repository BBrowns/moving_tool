// App Shell - Adaptive Navigation (Mobile/Desktop)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/core/widgets/responsive_wrapper.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  const AppShell({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  static const List<NavItem> navItems = [
    NavItem(
      path: '/dashboard',
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    NavItem(path: '/tasks', icon: Icons.check_circle_rounded, label: 'Taken'),
    NavItem(
      path: '/packing',
      icon: Icons.inventory_2_rounded,
      label: 'Inpakken',
    ),
    NavItem(
      path: '/shopping',
      icon: Icons.shopping_cart_rounded,
      label: 'Shopping',
    ),
    NavItem(path: '/expenses', icon: Icons.euro_rounded, label: 'Uitgaven'),
    NavItem(
      path: '/playbook',
      icon: Icons.menu_book_rounded,
      label: 'Playbook',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop || context.isTablet) {
      return _DesktopShell(
        navigationShell: navigationShell,
        navItems: navItems,
        children: children,
      );
    }

    return _MobileShell(
      navigationShell: navigationShell,
      navItems: navItems,
      children: children,
    );
  }
}

class _DesktopShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<NavItem> navItems;
  final List<Widget> children;

  const _DesktopShell({
    required this.navigationShell,
    required this.navItems,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isExtended = context.isDesktop;
    // We only show the first 6 items in Rail (Settings is bottom manually)
    final railItems = navItems;

    return Scaffold(
      body: Row(
        children: [
          // Wrap Rail and Settings in a Column to ensure Settings is at the bottom
          // without causing RenderFlex overflow inside the Rail's trailing widget.
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: IntrinsicHeight(
                    child: NavigationRail(
                      selectedIndex:
                          navigationShell.currentIndex < railItems.length
                          ? navigationShell.currentIndex
                          : 0,
                      onDestinationSelected: (index) =>
                          navigationShell.goBranch(index),
                      extended: isExtended,
                      labelType: isExtended
                          ? NavigationRailLabelType.none
                          : NavigationRailLabelType.all,
                      // Increase text size for better readability
                      selectedLabelTextStyle: context.textTheme.bodyLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.primary,
                          ),
                      unselectedLabelTextStyle: context.textTheme.bodyLarge
                          ?.copyWith(color: context.colors.onSurfaceVariant),
                      destinations: railItems
                          .map(
                            (item) => NavigationRailDestination(
                              icon: Icon(item.icon),
                              selectedIcon: Icon(item.icon, grade: 200),
                              label: Text(item.label),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: isExtended
                    ? TextButton.icon(
                        onPressed: () => context.push('/settings'),
                        icon: const Icon(Icons.settings_rounded),
                        label: const Text('Instellingen'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      )
                    : IconButton(
                        onPressed: () => context.push('/settings'),
                        icon: const Icon(Icons.settings_rounded),
                        tooltip: 'Instellingen',
                      ),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Use IndexedStack for desktop (instant switch)
          Expanded(
            child: IndexedStack(
              index: navigationShell.currentIndex,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final List<NavItem> navItems;
  final List<Widget> children;

  const _MobileShell({
    required this.navigationShell,
    required this.navItems,
    required this.children,
  });

  @override
  State<_MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<_MobileShell> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.navigationShell.currentIndex,
    );
  }

  @override
  void didUpdateWidget(covariant _MobileShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the logical index changes (e.g. from tapping tab bar or external nav), animate PageView
    if (widget.navigationShell.currentIndex !=
        oldWidget.navigationShell.currentIndex) {
      // Avoid animating if the PageView is already there (from swipe)
      if (_pageController.hasClients &&
          _pageController.page?.round() !=
              widget.navigationShell.currentIndex) {
        _pageController.animateToPage(
          widget.navigationShell.currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show top 5 items in bottom nav
    final displayItems = widget.navItems.take(5).toList();

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics:
            const NeverScrollableScrollPhysics(), // Disable swipe between tabs
        children: widget.children,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex < 5
            ? widget.navigationShell.currentIndex
            : 0,
        onDestinationSelected: (index) {
          widget.navigationShell.goBranch(index);
        },
        destinations: displayItems
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.icon, grade: 200),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class NavItem {
  final String path;
  final IconData icon;
  final String label;

  const NavItem({required this.path, required this.icon, required this.label});
}
