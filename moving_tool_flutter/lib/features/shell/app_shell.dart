// App Shell - Main navigation wrapper with sidebar/bottom nav
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  
  const AppShell({super.key, required this.child});

  static const List<_NavItem> _navItems = [
    _NavItem(path: '/dashboard', icon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavItem(path: '/tasks', icon: Icons.check_circle_rounded, label: 'Taken'),
    _NavItem(path: '/packing', icon: Icons.inventory_2_rounded, label: 'Inpakken'),
    _NavItem(path: '/shopping', icon: Icons.shopping_cart_rounded, label: 'Shopping'),
    _NavItem(path: '/costs', icon: Icons.euro_rounded, label: 'Kosten'),
    _NavItem(path: '/playbook', icon: Icons.book_rounded, label: 'Playbook'),
  ];

  int _getSelectedIndex(String location) {
    for (int i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _getSelectedIndex(location);
    final isWide = MediaQuery.of(context).size.width > 800;

    if (isWide) {
      // Desktop: Navigation Rail
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                context.go(_navItems[index].path);
              },
              extended: MediaQuery.of(context).size.width > 1200,
              destinations: _navItems.map((item) => NavigationRailDestination(
                icon: Icon(item.icon),
                label: Text(item.label),
              )).toList(),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: IconButton(
                      icon: const Icon(Icons.settings_rounded),
                      onPressed: () => context.go('/settings'),
                      tooltip: 'Instellingen',
                    ),
                  ),
                ),
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );
    } else {
      // Mobile: Bottom Navigation
      return Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            context.go(_navItems[index].path);
          },
          destinations: _navItems.take(5).map((item) => NavigationDestination(
            icon: Icon(item.icon),
            label: item.label,
          )).toList(),
        ),
      );
    }
  }
}

class _NavItem {
  final String path;
  final IconData icon;
  final String label;

  const _NavItem({
    required this.path,
    required this.icon,
    required this.label,
  });
}
