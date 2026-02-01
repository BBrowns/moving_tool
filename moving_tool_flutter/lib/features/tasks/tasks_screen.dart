// Tasks Screen - Task list with categories and CRUD
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/providers.dart';
import '../../data/models/models.dart';
import '../../core/theme/app_theme.dart';

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

    // Apply filters
    var filteredTasks = tasks;
    if (_filterCategory != null) {
      filteredTasks = filteredTasks.where((t) => t.category == _filterCategory).toList();
    }
    if (_filterStatus != null) {
      filteredTasks = filteredTasks.where((t) => t.status == _filterStatus).toList();
    }

    // Group by category with stable ordering
    final tasksByCategory = <TaskCategory, List<Task>>{};
    for (final task in filteredTasks) {
      tasksByCategory.putIfAbsent(task.category, () => []).add(task);
    }

    // Fixed category order
    final orderedCategories = TaskCategory.values
        .where((c) => tasksByCategory.containsKey(c))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Taken'),
        actions: [
          PopupMenuButton<TaskCategory?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
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
      ),
      body: tasks.isEmpty 
        ? _buildEmptyState()
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
              );
            },
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Taak'),
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

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    TaskCategory category = TaskCategory.overig;

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
              'Nieuwe taak',
              style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              autofocus: true,
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
                  ref.read(taskProvider.notifier).add(
                    title: titleController.text,
                    category: category,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Toevoegen'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final TaskCategory category;
  final List<Task> tasks;
  final List<User> users;
  final Function(String) onToggle;
  final Function(String) onDelete;

  const _CategorySection({
    required this.category,
    required this.tasks,
    required this.users,
    required this.onToggle,
    required this.onDelete,
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
        ...tasks.map((task) => _TaskCard(
          task: task,
          assignee: users.where((u) => u.id == task.assigneeId).firstOrNull,
          onToggle: () => onToggle(task.id),
          onDelete: () => onDelete(task.id),
        )),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final User? assignee;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    this.assignee,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == TaskStatus.done;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            isDone ? Icons.check_circle : 
            task.status == TaskStatus.inProgress ? Icons.pending :
            Icons.radio_button_unchecked,
            color: isDone ? AppTheme.success : 
                   task.status == TaskStatus.inProgress ? AppTheme.warning :
                   context.colors.onSurfaceVariant,
          ),
          onPressed: onToggle,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? context.colors.onSurfaceVariant : null,
          ),
        ),
        subtitle: task.deadline != null ? Text(
          '📅 ${task.deadline!.day}-${task.deadline!.month}-${task.deadline!.year}',
          style: context.textTheme.bodySmall,
        ) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (assignee != null)
              CircleAvatar(
                radius: 14,
                backgroundColor: Color(int.parse(assignee!.color.replaceFirst('#', '0xFF'))),
                child: Text(
                  assignee!.name[0].toUpperCase(),
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
