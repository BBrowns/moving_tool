import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instellingen'),
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Uiterlijk'),
          SwitchListTile(
            title: const Text('Donkere Modus'),
            subtitle: Text(
              themeMode == ThemeMode.system
                  ? 'Systeem instelling volgen'
                  : themeMode == ThemeMode.dark
                      ? 'Aan'
                      : 'Uit',
            ),
            secondary: Icon(
              themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
            ),
            value: themeMode == ThemeMode.dark,
            onChanged: (bool value) {
              ref.read(themeModeProvider.notifier).set(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
            },
          ),
          ListTile(
            title: const Text('Systeem Thema'),
            subtitle: const Text('Volg instellingen van je apparaat'),
            leading: const Icon(Icons.brightness_auto),
            trailing: Switch(
              value: themeMode == ThemeMode.system,
              onChanged: (bool value) {
                if (value) {
                  ref.read(themeModeProvider.notifier).set(ThemeMode.system);
                } else {
                  // Default to light if turning off system mode
                  ref.read(themeModeProvider.notifier).set(ThemeMode.light);
                }
              },
            ),
          ),
          const Divider(),
          const _SectionHeader(title: 'Over'),
          ListTile(
            title: const Text('Versie'),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
