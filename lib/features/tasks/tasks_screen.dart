import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moving_tool_flutter/features/tasks/presentation/providers/task_providers.dart';
import 'package:moving_tool_flutter/features/tasks/domain/entities/task.dart';
import 'package:moving_tool_flutter/core/models/models.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/core/widgets/responsive_scaffold.dart';
import 'package:moving_tool_flutter/core/widgets/responsive_wrapper.dart';
import 'package:moving_tool_flutter/features/tasks/presentation/widgets/task_card.dart';
import 'package:moving_tool_flutter/data/providers/providers.dart'; // For projectProvider
import 'package:flutter_animate/flutter_animate.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  TaskCategory? _filterCategory;
  TaskStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);
    final project = ref.watch(projectProvider);
    final isDesktop = context.isDesktop;

    // Apply filters
    var filteredTasks = tasks;
    if (_filterCategory != null) {
      filteredTasks = filteredTasks.where((t) => t.category == _filterCategory).toList();
    }
    if (_filterStatus != null) {
      filteredTasks = filteredTasks.where((t) => t.status == _filterStatus).toList();
    }

    // Group by category with stable ordering (Mobile)
    final tasksByCategory = <TaskCategory, List<Task>>{};
    for (final task in filteredTasks) {
      tasksByCategory.putIfAbsent(task.category, () => []).add(task);
    }
    final orderedCategories = TaskCategory.values
        .where((c) => tasksByCategory.containsKey(c))
        .toList();

    // Group by status (Desktop)
    final tasksByStatus = <TaskStatus, List<Task>>{};
    for (final task in filteredTasks) {
      tasksByStatus.putIfAbsent(task.status, () => []).add(task);
    }

    return ResponsiveScaffold(
      title: 'Taken',
      fabLabel: 'Taak',
      fabIcon: Icons.add,
      onFabPressed: () => _showTaskDialog(context),
      actions: [
        if (_filterCategory != null || _filterStatus != null)
           IconButton(
            icon: const Icon(Icons.filter_alt_off),
            tooltip: 'Filter wissen',
            onPressed: () => setState(() {
              _filterCategory = null;
              _filterStatus = null;
            }),
          ),
        PopupMenuButton<TaskCategory?>(
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filter op categorie',
          onSelected: (value) => setState(() => _filterCategory = value),
          itemBuilder: (context) => [
            const PopupMenuItem(value: null, child: Text('Alle categorieën')),
            const PopupMenuDivider(),
            ...TaskCategory.values.map((c) => PopupMenuItem(
              value: c,
              child: Text(c.label),
            )),
          ],
        ),
      ],
      body: tasks.isEmpty 
        ? _buildEmptyState()
        : isDesktop
            ? _buildKanbanView(tasksByStatus, project?.users ?? [])
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orderedCategories.length,
                itemBuilder: (context, index) {
                  final category = orderedCategories[index];
                  final categoryTasks = tasksByCategory[category]!;
                  
                  return _CategorySection(
                    category: category,
                    tasks: categoryTasks,
                    users: project?.users ?? [],
                    onToggle: (id) => ref.read(taskProvider.notifier).toggleStatus(id),
                    onDelete: (id) => ref.read(taskProvider.notifier).delete(id),
                    onEdit: (task) => _showTaskDialog(context, task: task),
                  ).animate().fade(duration: 400.ms, delay: (index * 100).ms).slideX(begin: -0.1, end: 0);
                },
              ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📝', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Nog geen taken',
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Voeg je eerste taak toe',
            style: TextStyle(color: context.colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanView(Map<TaskStatus, List<Task>> tasksByStatus, List<User> users) {
    return ResponsiveWrapper(
      maxWidth: 1400,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: TaskStatus.values.map((status) {
          final tasks = tasksByStatus[status] ?? [];
          return Expanded(
            child: _StatusColumn(
              status: status,
              tasks: tasks,
              users: users,
              onToggle: (id) => ref.read(taskProvider.notifier).toggleStatus(id),
              onDelete: (id) => ref.read(taskProvider.notifier).delete(id),
              onStatusChange: (id, newStatus) => ref.read(taskProvider.notifier).updateStatus(id, newStatus),
              onEdit: (task) => _showTaskDialog(context, task: task),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showTaskDialog(BuildContext context, {Task? task}) {
    final isEditing = task != null;
    final titleController = TextEditingController(text: task?.title);
    TaskCategory category = task?.category ?? TaskCategory.overig;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing ? 'Taak bewerken' : 'Nieuwe taak',
              style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              autofocus: !isEditing,
              decoration: const InputDecoration(
                labelText: 'Titel',
                hintText: 'Wat moet er gedaan worden?',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskCategory>(
              value: category,
              decoration: const InputDecoration(labelText: 'Categorie'),
              items: TaskCategory.values.map((c) => DropdownMenuItem(
                value: c,
                child: Text(c.label),
              )).toList(),
              onChanged: (value) => category = value!,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  if (isEditing) {
                    ref.read(taskProvider.notifier).update(
                      task!.copyWith(
                        title: titleController.text,
                        category: category,
                      )
                    );
                  } else {
                    ref.read(taskProvider.notifier).add(
                      title: titleController.text,
                      category: category,
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(isEditing ? 'Opslaan' : 'Toevoegen'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _StatusColumn extends StatelessWidget {
  final TaskStatus status;
  final List<Task> tasks;
  final List<User> users;
  final Function(String) onToggle;
  final Function(String) onDelete;
  final Function(String, TaskStatus) onStatusChange;
  final Function(Task) onEdit;

  const _StatusColumn({
    required this.status,
    required this.tasks,
    required this.users,
    required this.onToggle,
    required this.onDelete,
    required this.onStatusChange,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case TaskStatus.todo:
        statusColor = context.colors.onSurface;
        statusIcon = Icons.radio_button_unchecked;
        break;
      case TaskStatus.inProgress:
        statusColor = AppTheme.warning;
        statusIcon = Icons.pending_outlined;
        break;
      case TaskStatus.done:
        statusColor = AppTheme.success;
        statusIcon = Icons.check_circle_outline;
        break;
    }

    return DragTarget<Task>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) => onStatusChange(details.data.id, status),
      builder: (context, candidateData, rejectedData) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          elevation: candidateData.isNotEmpty ? 4 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: candidateData.isNotEmpty 
                  ? AppTheme.primary 
                  : context.colors.outlineVariant.withValues(alpha: 0.5),
              width: candidateData.isNotEmpty ? 2 : 1,
            ),
          ),
          color: candidateData.isNotEmpty 
              ? AppTheme.primary.withValues(alpha: 0.05)
              : context.colors.surfaceContainerLowest,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Column Header
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        status.label,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${tasks.length}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                // Tasks List
                Expanded(
                  child: tasks.isEmpty
                  ? Center(
                      child: Text(
                        'Geen taken',
                        style: TextStyle(
                          color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        final card = TaskCard(
                          task: task,
                          assignee: users.where((u) => u.id == task.assigneeId).firstOrNull,
                          onToggle: () => onToggle(task.id),
                          onDelete: () => onDelete(task.id),
                          onTap: () => onEdit(task),
                        );

                        return Draggable<Task>(
                          data: task,
                          feedback: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              width: 300,
                              child: card,
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: card,
                          ),
                          child: card,
                        );
                      },
                    ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}

class _CategorySection extends StatelessWidget {
  final TaskCategory category;
  final List<Task> tasks;
  final List<User> users;
  final Function(String) onToggle;
  final Function(String) onDelete;
  final Function(Task) onEdit;

  const _CategorySection({
    super.key,
    required this.category,
    required this.tasks,
    required this.users,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Text(category.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                category.label.replaceFirst(RegExp(r'^[^\s]+\s'), ''),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tasks.length}',
                  style: context.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        ...tasks.map((task) => TaskCard(
          task: task,
          assignee: users.where((u) => u.id == task.assigneeId).firstOrNull,
          onToggle: () => onToggle(task.id),
          onDelete: () => onDelete(task.id),
          onTap: () => onEdit(task),
        )),
        const SizedBox(height: 16),
      ],
    );
  }
}
