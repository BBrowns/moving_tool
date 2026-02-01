// Playbook Screen - Journal and notes
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/providers.dart';
import '../../data/models/models.dart';
import '../../core/theme/app_theme.dart';

class PlaybookScreen extends ConsumerWidget {
  const PlaybookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journal = ref.watch(journalProvider);
    final notes = ref.watch(notesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Playbook'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Dagboek'),
              Tab(text: 'Notities'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _JournalTab(entries: journal),
            _NotesTab(
              notes: notes,
              onAdd: () => _showAddNoteDialog(context, ref),
              onTogglePin: (id) => ref.read(notesProvider.notifier).togglePin(id),
              onDelete: (id) => ref.read(notesProvider.notifier).delete(id),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddNoteDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Notitie'),
        ),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16, right: 16, top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Nieuwe notitie', style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Titel'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Inhoud', alignLabelWithHint: true),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  ref.read(notesProvider.notifier).add(
                    title: titleController.text,
                    content: contentController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Opslaan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalTab extends StatelessWidget {
  final List<JournalEntry> entries;

  const _JournalTab({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📔', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('Nog geen activiteit', style: context.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Activiteiten worden hier automatisch bijgehouden', 
                style: TextStyle(color: context.colors.onSurfaceVariant)),
          ],
        ),
      );
    }

    // Group by date
    final grouped = <String, List<JournalEntry>>{};
    for (final entry in entries) {
      final key = '${entry.timestamp.day}-${entry.timestamp.month}-${entry.timestamp.year}';
      grouped.putIfAbsent(key, () => []).add(entry);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final dateKey = grouped.keys.elementAt(index);
        final dayEntries = grouped[dateKey]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                dateKey,
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
            ...dayEntries.map((entry) => Card(
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
            )),
          ],
        );
      },
    );
  }
}

class _NotesTab extends StatelessWidget {
  final List<PlaybookNote> notes;
  final VoidCallback onAdd;
  final Function(String) onTogglePin;
  final Function(String) onDelete;

  const _NotesTab({
    required this.notes,
    required this.onAdd,
    required this.onTogglePin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📝', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('Nog geen notities', style: context.textTheme.titleLarge),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Eerste notitie'),
            ),
          ],
        ),
      );
    }

    // Sort: pinned first
    final sorted = [...notes]..sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final note = sorted[index];
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
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: () => onTogglePin(note.id),
                  child: Row(
                    children: [
                      Icon(note.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
                      const SizedBox(width: 8),
                      Text(note.isPinned ? 'Losmaken' : 'Vastpinnen'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: () => onDelete(note.id),
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
      },
    );
  }
}
