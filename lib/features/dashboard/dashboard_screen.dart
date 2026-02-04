// Dashboard Screen - Bento Grid Layout (MovingOS)
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moving_tool_flutter/core/models/models.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/core/widgets/responsive_wrapper.dart';
import 'package:moving_tool_flutter/data/providers/providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    final tasks = ref.watch(taskProvider);
    final boxes = ref.watch(boxProvider);
    final shopping = ref.watch(shoppingProvider);
    final expenses = ref.watch(expenseProvider);
    final journal = ref.watch(journalProvider);

    if (project == null) {
      return Center(
        child: AppTheme.isTestMode
            ? const Text('Loading...') // Static for tests
            : const CircularProgressIndicator(),
      );
    }

    // Stats
    final completedTasks = tasks.where((t) => t.status.name == 'done').length;
    final packedBoxes = boxes
        .where((b) => b.status.name == 'packed' || b.status.name == 'moved')
        .length;
    final purchasedItems = shopping
        .where((s) => s.status.name == 'purchased')
        .length;
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: SafeArea(
        child: ResponsiveWrapper(
          maxWidth: 1200,
          child: CustomScrollView(
            slivers: [
              // ... (skip lines)
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Header Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Hallo ${project.members.isNotEmpty ? project.members.first.name : "Verhuizer"}! 👋',
                            style: context.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.onSurface,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            if (isMobile)
                              IconButton(
                                onPressed: () => context.push('/settings'),
                                icon: const Icon(Icons.settings_rounded),
                                tooltip: 'Instellingen',
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nog ${project.daysUntilMove} dagen tot de grote dag.',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
              // Playbook Hero Section
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                sliver: SliverToBoxAdapter(
                  child: _PlaybookHeroCard(
                    onTap: () => context.go('/playbook'),
                  ),
                ),
              ),

              // Bento Grid - Stats & Actions
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 2 : 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85, // Taller tiles for better look
                  ),
                  delegate: SliverChildListDelegate(
                    AppTheme.isTestMode
                        ? [
                            _BentoCard(
                              title: 'Taken',
                              value: '$completedTasks/${tasks.length}',
                              subtitle: 'Afgerond',
                              icon: Icons.check_circle_rounded,
                              color: const Color(0xFF4CAF50), // Vibrant Green
                              onTap: () => context.go('/tasks'),
                            ),
                            _BentoCard(
                              title: 'Inpakken',
                              value: '$packedBoxes/${boxes.length}',
                              subtitle: 'Dozen Klaar',
                              icon: Icons.inventory_2_rounded,
                              color: const Color(0xFF2196F3), // Vibrant Blue
                              onTap: () => context.go('/packing'),
                            ),
                            _BentoCard(
                              title: 'Shopping',
                              value: '$purchasedItems/${shopping.length}',
                              subtitle: 'Gekocht',
                              icon: Icons.shopping_bag_rounded,
                              color: const Color(0xFFFF9800), // Vibrant Orange
                              onTap: () => context.go('/shopping'),
                            ),
                            _BentoCard(
                              title: 'Budget',
                              value: '€${totalExpenses.toStringAsFixed(0)}',
                              subtitle: 'Uitgegeven',
                              icon: Icons.euro_rounded,
                              color: const Color(0xFF9C27B0), // Vibrant Purple
                              onTap: () => context.go('/expenses'),
                            ),
                          ]
                        : [
                                _BentoCard(
                                  title: 'Taken',
                                  value: '$completedTasks/${tasks.length}',
                                  subtitle: 'Afgerond',
                                  icon: Icons.check_circle_rounded,
                                  color: const Color(0xFF4CAF50),
                                  onTap: () => context.go('/tasks'),
                                ),
                                _BentoCard(
                                  title: 'Inpakken',
                                  value: '$packedBoxes/${boxes.length}',
                                  subtitle: 'Dozen Klaar',
                                  icon: Icons.inventory_2_rounded,
                                  color: const Color(0xFF2196F3),
                                  onTap: () => context.go('/packing'),
                                ),
                                _BentoCard(
                                  title: 'Shopping',
                                  value: '$purchasedItems/${shopping.length}',
                                  subtitle: 'Gekocht',
                                  icon: Icons.shopping_bag_rounded,
                                  color: const Color(0xFFFF9800),
                                  onTap: () => context.go('/shopping'),
                                ),
                                _BentoCard(
                                  title: 'Budget',
                                  value: '€${totalExpenses.toStringAsFixed(0)}',
                                  subtitle: 'Uitgegeven',
                                  icon: Icons.euro_rounded,
                                  color: const Color(0xFF9C27B0),
                                  onTap: () => context.go('/expenses'),
                                ),
                              ]
                              .animate(interval: 50.ms)
                              .fade(duration: 400.ms)
                              .scaleXY(
                                begin: 0.9,
                                end: 1.0,
                                curve: Curves.easeOutBack,
                              ),
                  ),
                ),
              ),

              // Recent Activity Section
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recente Activiteit',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (journal.isEmpty)
                        _EmptyState()
                      else
                        ...journal
                            .take(5)
                            .map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _ActivityTile(entry: entry),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaybookHeroCard extends StatelessWidget {
  const _PlaybookHeroCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 160, // Increased height to prevent overflow
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.colors.primary, context.colors.primaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              // Background pattern decoration
              Positioned(
                right: -20,
                bottom: -40,
                child: Icon(
                  Icons.book_rounded,
                  size: 180,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Jouw Gids',
                              style: context.textTheme.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Moving Playbook',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tips & Tricks voor een soepele verhuizing',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  const _BentoCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header: Icon + Arrow
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: isDark ? Colors.white70 : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),

                // Content with scale-down protection
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: context.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white70
                                : Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? Colors.white38
                                : Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.entry});
  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              entry.type.icon,
              size: 20,
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDate(entry.timestamp),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m geleden';
    if (diff.inHours < 24) return '${diff.inHours}u geleden';
    if (diff.inDays < 7) return '${diff.inDays}d geleden';
    return '${date.day}/${date.month}';
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, color: context.colors.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(
            'Nog geen recente activiteit',
            style: TextStyle(color: context.colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
