// Settings Screen - App configuration and data management
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/core/widgets/responsive_wrapper.dart';
import 'package:moving_tool_flutter/data/providers/providers.dart';
import 'package:moving_tool_flutter/data/services/database_service.dart';
import 'package:moving_tool_flutter/data/services/export_service.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    final projects = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Instellingen')),
      body: ResponsiveWrapper(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // My Moves section
            Card(
              child: ListTile(
                leading: const Text('📦', style: TextStyle(fontSize: 32)),
                title: const Text('Mijn Verhuizingen'),
                subtitle: Text(
                  '${projects.length} verhuizing${projects.length == 1 ? '' : 'en'}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/projects'),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Huidige verhuizing',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Project info
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.home_rounded),
                    title: Text(project?.name ?? 'Geen verhuizing'),
                    subtitle: project != null
                        ? Text(
                            'Verhuisdatum: ${project.movingDate.day}-${project.movingDate.month}-${project.movingDate.year}',
                          )
                        : null,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Edit project
                    },
                  ),
                  if (project != null) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.delete_outline,
                        color: AppTheme.error,
                      ),
                      title: const Text(
                        'Verhuizing verwijderen',
                        style: TextStyle(color: AppTheme.error),
                      ),
                      onTap: () =>
                          _showDeleteProjectConfirmation(context, ref, project),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Gebruikers',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  if (project != null)
                    ...project.users.map(
                      (user) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(
                            int.parse(user.color.replaceFirst('#', '0xFF')),
                          ),
                          child: Text(
                            user.name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(user.name),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: AppTheme.error,
                          ),
                          onPressed: () => ref
                              .read(projectProvider.notifier)
                              .removeUser(user.id),
                          tooltip: 'Verwijder gebruiker',
                        ),
                      ),
                    ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: const Text('Gebruiker toevoegen'),
                    onTap: () => _showAddUserDialog(context, ref),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Uiterlijk',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  Consumer(
                    builder: (context, ref, _) {
                      final themeMode = ref.watch(themeModeProvider);
                      return SwitchListTile(
                        title: const Text('Donkere Modus'),
                        subtitle: Text(
                          themeMode == ThemeMode.system
                              ? 'Systeem instelling volgen'
                              : themeMode == ThemeMode.dark
                              ? 'Aan'
                              : 'Uit',
                        ),
                        secondary: Icon(
                          themeMode == ThemeMode.dark
                              ? Icons.dark_mode
                              : Icons.light_mode,
                        ),
                        value: themeMode == ThemeMode.dark,
                        onChanged: (bool value) {
                          ref
                              .read(themeModeProvider.notifier)
                              .set(value ? ThemeMode.dark : ThemeMode.light);
                        },
                      );
                    },
                  ),
                  const Divider(height: 1),
                  Consumer(
                    builder: (context, ref, _) {
                      final themeMode = ref.watch(themeModeProvider);
                      return ListTile(
                        title: const Text('Systeem Thema'),
                        subtitle: const Text(
                          'Volg instellingen van je apparaat',
                        ),
                        leading: const Icon(Icons.brightness_auto),
                        trailing: Switch(
                          value: themeMode == ThemeMode.system,
                          onChanged: (bool value) {
                            if (value) {
                              ref
                                  .read(themeModeProvider.notifier)
                                  .set(ThemeMode.system);
                            } else {
                              // Default to light if turning off system mode
                              ref
                                  .read(themeModeProvider.notifier)
                                  .set(ThemeMode.light);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'AI Instellingen',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.vpn_key),
                    title: const Text('Gemini API Key'),
                    subtitle: Text(
                      DatabaseService.getSetting('gemini_api_key') == null
                          ? 'Niet ingesteld'
                          : '••••••••',
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showApiKeyDialog(
                      context,
                      ref,
                      'gemini_api_key',
                      'Gemini',
                      'aistudio.google.com/app/apikey',
                    ),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.computer),
                    title: Text('Ollama (Lokaal)'),
                    subtitle: Text('Fallback - installeer via ollama.com'),
                    trailing: Icon(Icons.info_outline),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Data',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.file_download),
                    title: const Text('Exporteren'),
                    subtitle: const Text('Download je data als CSV'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showExportDialog(context, ref, project),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_forever,
                      color: AppTheme.error,
                    ),
                    title: const Text(
                      'Alle data wissen',
                      style: TextStyle(color: AppTheme.error),
                    ),
                    onTap: () => _showDeleteConfirmation(context, ref),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Over',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Versie'),
                    trailing: Text('1.0.0'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.code),
                    title: Text('Gebouwd met Flutter'),
                    subtitle: Text('Cross-platform app'),
                    trailing: FlutterLogo(size: 24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alle data wissen?'),
        content: const Text(
          'Dit kan niet ongedaan worden gemaakt. Al je taken, dozen, en uitgaven worden verwijderd.',
        ),
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

  void _showDeleteProjectConfirmation(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.warning_rounded,
          color: AppTheme.error,
          size: 48,
        ),
        title: const Text('Verhuizing verwijderen?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weet je zeker dat je "${project.name}" wilt verwijderen?'),
            const SizedBox(height: 8),
            Text(
              'Alle taken, dozen, inkopen en uitgaven worden permanent verwijderd.',
              style: TextStyle(color: context.colors.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(projectsProvider.notifier).delete(project.id);

              // Reload providers
              ref.read(projectProvider.notifier).load();
              ref.read(projectsProvider.notifier).load();

              if (context.mounted) {
                final hasProjects = ref.read(projectsProvider).isNotEmpty;
                if (!hasProjects) {
                  context.go('/onboarding');
                }
              }
            },
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(
    BuildContext context,
    WidgetRef ref,
    Project? project,
  ) {
    if (project == null) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Exporteer Data',
                  style: context.textTheme.titleLarge,
                ),
              ),
              const Divider(height: 1),
              _buildExportOption(
                context,
                icon: Icons.backup,
                title: 'Volledige backup (JSON)',
                subtitle: 'Deel of sla op voor backup',
                onShare: () async {
                  Navigator.pop(context);
                  await ExportService.exportProjectData(
                    project,
                    download: false,
                  );
                },
                onDownload: () async {
                  Navigator.pop(context);
                  await ExportService.exportProjectData(
                    project,
                    download: true,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opgeslagen in Documents map'),
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 1),
              _buildExportOption(
                context,
                icon: Icons.table_chart,
                title: 'Uitgaven rapport (CSV)',
                subtitle: 'Voor Excel of administratie',
                onShare: () async {
                  Navigator.pop(context);
                  await ExportService.exportExpensesCsv(
                    project,
                    download: false,
                  );
                },
                onDownload: () async {
                  Navigator.pop(context);
                  await ExportService.exportExpensesCsv(
                    project,
                    download: true,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opgeslagen in Downloads map'),
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 1),
              _buildExportOption(
                context,
                icon: Icons.auto_awesome,
                title: 'Ultiem Overzicht (Markdown)',
                subtitle: 'Compleet overzicht voor AI of print',
                onShare: () async {
                  Navigator.pop(context);
                  await ExportService.exportLlmOverview(
                    project,
                    download: false,
                  );
                },
                onDownload: () async {
                  Navigator.pop(context);
                  await ExportService.exportLlmOverview(
                    project,
                    download: true,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ultiem Overzicht opgeslagen!'),
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 1),
              _buildExportOption(
                context,
                icon: Icons.psychology,
                title: 'AI Samenvatting',
                subtitle: 'Automatische samenvatting via Gemini',
                onShare: () async {
                  Navigator.pop(context);
                  await ExportService.exportLlmSummary(
                    project,
                    download: false,
                  );
                },
                onDownload: () async {
                  Navigator.pop(context);
                  await ExportService.exportLlmSummary(project, download: true);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('AI Samenvatting opgeslagen!'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String selectedColor = '#6366F1';
    final colors = [
      '#6366F1',
      '#8B5CF6',
      '#EC4899',
      '#10B981',
      '#F59E0B',
      '#EF4444',
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Gebruiker toevoegen',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Naam',
                  hintText: 'bijv. Jan',
                ),
              ),
              const SizedBox(height: 16),
              Text('Kies een kleur', style: context.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: colors
                    .map(
                      (color) => GestureDetector(
                        onTap: () => setModalState(() => selectedColor = color),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(
                              int.parse(color.replaceFirst('#', '0xFF')),
                            ),
                            shape: BoxShape.circle,
                            border: selectedColor == color
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    ref
                        .read(projectProvider.notifier)
                        .addUser(nameController.text, selectedColor);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Toevoegen'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showApiKeyDialog(
    BuildContext context,
    WidgetRef ref,
    String settingKey,
    String providerName,
    String url,
  ) {
    final controller = TextEditingController(
      text: DatabaseService.getSetting(settingKey) ?? '',
    );

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$providerName API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voer je $providerName API key in om AI samenvattingen te gebruiken.',
            ),
            const SizedBox(height: 8),
            const Text(
              'Gratis key aanmaken op:',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              url,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'Plak hier je key',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () async {
              await DatabaseService.saveSetting(settingKey, controller.text);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$providerName API key opgeslagen!')),
                );
              }
            },
            child: const Text('Opslaan'),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onShare,
    required VoidCallback onDownload,
  }) {
    return ExpansionTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton.tonal(
                onPressed: onShare,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Delen'),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: onDownload,
                icon: const Icon(Icons.download),
                label: const Text('Opslaan'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
