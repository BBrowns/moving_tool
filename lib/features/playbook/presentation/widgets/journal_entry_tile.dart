import 'package:flutter/material.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/features/playbook/domain/entities/journal_entry.dart';

class JournalEntryTile extends StatelessWidget {
  final JournalEntry entry;

  const JournalEntryTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(entry.type.icon, size: 24, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(entry.title),
        subtitle: entry.description != null ? Text(entry.description!) : null,
        trailing: Text(
          '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}',
          style: context.textTheme.bodySmall,
        ),
      ),
    );
  }
}
