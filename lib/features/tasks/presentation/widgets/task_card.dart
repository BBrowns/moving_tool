import 'package:flutter/material.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/features/tasks/domain/entities/task.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final User? assignee;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.assignee,
    required this.onToggle,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == TaskStatus.done;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
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
