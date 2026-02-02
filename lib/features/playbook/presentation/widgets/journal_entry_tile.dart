import 'package:flutter/material.dart';
import 'package:moving_tool_flutter/features/playbook/domain/entities/journal_entry.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';

class JournalEntryTile extends StatelessWidget {
  final JournalEntry entry;

  const JournalEntryTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(entry.type.icon, style: const TextStyle(fontSize: 24)),
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
