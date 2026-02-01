// Settings Screen - App configuration and data management
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/providers.dart';
import '../../data/services/database_service.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Instellingen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Project info
          Card(
            child: ListTile(
              leading: const Text('📦', style: TextStyle(fontSize: 32)),
              title: Text(project?.name ?? 'Verhuistool'),
              subtitle: project != null 
                  ? Text('Verhuisdatum: ${project.movingDate.day}-${project.movingDate.month}-${project.movingDate.year}')
                  : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Edit project
              },
            ),
          ),
          
          const SizedBox(height: 16),
          Text('Gebruikers', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (project != null && project.users.isNotEmpty)
            Card(
              child: Column(
                children: project.users.map((user) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(int.parse(user.color.replaceFirst('#', '0xFF'))),
                    child: Text(user.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(user.name),
                )).toList(),
              ),
            )
          else
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Gebruiker toevoegen'),
                onTap: () {
                  // TODO: Add user
                },
              ),
            ),
          
          const SizedBox(height: 24),
          Text('Data', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download),
                  title: const Text('Exporteren'),
                  subtitle: const Text('Download je data als CSV'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export komt binnenkort!')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: AppTheme.error),
                  title: const Text('Alle data wissen', style: TextStyle(color: AppTheme.error)),
                  onTap: () => _showDeleteConfirmation(context, ref),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          Text('Over', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Versie'),
                  trailing: Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Gebouwd met Flutter'),
                  subtitle: const Text('Cross-platform app'),
                  trailing: const FlutterLogo(size: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alle data wissen?'),
        content: const Text('Dit kan niet ongedaan worden gemaakt. Al je taken, dozen, en uitgaven worden verwijderd.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuleren'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              await DatabaseService.clearAll();
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/onboarding');
              }
            },
            child: const Text('Wissen'),
          ),
        ],
      ),
    );
  }
}
