// Projects Screen - "Mijn Verhuizingen" overview
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/core/widgets/responsive_scaffold.dart';
import 'package:moving_tool_flutter/core/widgets/responsive_wrapper.dart';
import 'package:moving_tool_flutter/data/providers/providers.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';
import 'package:moving_tool_flutter/seeds/scenario_seed.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  @override
  void initState() {
    super.initState();
    // Force reload projects to ensure we have latest data
    Future.microtask(() {
      ref.read(projectsProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final activeProject = ref.watch(projectProvider);

    return ResponsiveScaffold(
      title: 'Mijn Verhuizingen',
      fabHeroTag: 'projects_fab',
      fabLabel: 'Nieuwe verhuizing',
      fabIcon: Icons.add,
      onFabPressed: () => context.push('/onboarding'),
      actions: [
        IconButton(
          icon: const Icon(Icons.science_outlined),
          tooltip: 'Demo Data Genereren',
          onPressed: () => _seedDemoProject(ref),
        ),
      ],
      body: projects.isEmpty
          ? _buildEmptyState(context)
          : ResponsiveWrapper(
              maxWidth: 800,
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  final isActive = activeProject?.id == project.id;

                  return _ProjectCard(
                    project: project,
                    isActive: isActive,
                    onTap: () => _selectProject(context, ref, project.id),
                    onDelete: () => _confirmDelete(context, ref, project),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📦', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('Nog geen verhuizingen', style: context.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Start je eerste verhuizing om te beginnen',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/onboarding'),
            icon: const Icon(Icons.add),
            label: const Text('Nieuwe verhuizing'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _seedDemoProject(ref),
            child: const Text('Probeer Demo Project'),
          ),
        ],
      ),
    );
  }

  Future<void> _seedDemoProject(WidgetRef ref) async {
    await seedOnsAppartement(ref);
    // Refresh
    ref.read(projectsProvider.notifier).load();
  }

  void _selectProject(
    BuildContext context,
    WidgetRef ref,
    String projectId,
  ) async {
    await ref.read(projectProvider.notifier).setActive(projectId);
    ref.read(projectsProvider.notifier).load();

    // Reload all data for the new project
    // Reload all data for the new project
    await Future.wait([
      ref.read(taskProvider.notifier).load(),
      ref.read(roomProvider.notifier).load(),
      ref.read(boxProvider.notifier).load(),
      ref.read(shoppingProvider.notifier).load(),
      ref.read(expenseProvider.notifier).load(),
    ]);

    if (context.mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/dashboard');
      }
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Project project) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(projectsProvider.notifier).delete(project.id);

              // Reload active project
              ref.read(projectProvider.notifier).load();
              ref.read(projectsProvider.notifier).load();

              if (context.mounted) {
                final hasProjects = ref.read(projectsProvider).isNotEmpty;
                if (!hasProjects) {
                  context.go('/onboarding');
                } else if (context.canPop()) {
                  context
                      .pop(); // Return to previous screen (Dashboard) if valid
                } else {
                  context.go('/dashboard');
                }
              }
            },
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
  });
  final Project project;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy', 'nl_NL');
    final daysUntil = project.daysUntilMove;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      shape: isActive
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppTheme.primary, width: 2),
            )
          : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('📦', style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            project.name,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Actief',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(project.movingDate),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStatusChip(context, daysUntil),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: AppTheme.error),
                        SizedBox(width: 12),
                        Text(
                          'Verwijderen',
                          style: TextStyle(color: AppTheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, int daysUntil) {
    final Color color;
    final String text;

    if (daysUntil < 0) {
      color = context.colors.onSurfaceVariant;
      text = 'Voltooid';
    } else if (daysUntil == 0) {
      color = AppTheme.error;
      text = 'Vandaag!';
    } else if (daysUntil <= 7) {
      color = AppTheme.warning;
      text = 'Nog $daysUntil dagen';
    } else if (daysUntil <= 30) {
      color = AppTheme.primary;
      text = 'Nog $daysUntil dagen';
    } else {
      color = AppTheme.success;
      text = 'Nog $daysUntil dagen';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: context.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
