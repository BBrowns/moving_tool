import 'package:flutter/material.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/features/playbook/domain/entities/playbook_note.dart';

class NoteCard extends StatelessWidget {
  final PlaybookNote note;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTogglePin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: note.isPinned 
            ? const Icon(Icons.push_pin, color: AppTheme.warning)
            : const Icon(Icons.note_outlined),
        title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: note.content.isNotEmpty 
            ? Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis)
            : null,
        trailing: PopupMenuButton<void>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem<void>(
              onTap: onTogglePin,
              child: Row(
                children: [
                  Icon(note.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
                  const SizedBox(width: 8),
                  Text(note.isPinned ? 'Losmaken' : 'Vastpinnen'),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: onDelete,
              child: const Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Verwijderen', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
