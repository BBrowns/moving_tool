import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moving_tool_flutter/features/playbook/presentation/providers/playbook_providers.dart';
import 'package:moving_tool_flutter/features/playbook/domain/entities/journal_entry.dart';
import 'package:moving_tool_flutter/features/playbook/domain/entities/playbook_note.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/features/playbook/presentation/widgets/journal_entry_tile.dart';
import 'package:moving_tool_flutter/features/playbook/presentation/widgets/note_card.dart';

class PlaybookScreen extends ConsumerStatefulWidget {
  const PlaybookScreen({super.key});

  @override
  ConsumerState<PlaybookScreen> createState() => _PlaybookScreenState();
}

class _PlaybookScreenState extends ConsumerState<PlaybookScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final journal = ref.watch(journalProvider);
    final notes = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Playbook'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dagboek'),
            Tab(text: 'Notities'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _JournalTab(
            entries: journal,
            onAdd: () => _showAddJournalEntryDialog(context, ref),
          ),
          _NotesTab(
            notes: notes,
            onAdd: () => _showAddNoteDialog(context, ref),
            onTogglePin: (id) => ref.read(notesProvider.notifier).togglePin(id),
            onDelete: (id) => ref.read(notesProvider.notifier).delete(id),
          ),
        ],
      ),
      floatingActionButtonLocation: MediaQuery.of(context).size.width > 600 
          ? FloatingActionButtonLocation.centerFloat 
          : FloatingActionButtonLocation.endFloat,
      floatingActionButton: (_tabController.index == 0 && journal.isEmpty) || 
                            (_tabController.index == 1 && notes.isEmpty)
          ? null // Hide FAB if empty (EmptyState button takes over)
          : FloatingActionButton.extended(
              onPressed: _tabController.index == 0 
                  ? () => _showAddJournalEntryDialog(context, ref)
                  : () => _showAddNoteDialog(context, ref),
              icon: Icon(_tabController.index == 0 ? Icons.edit_note : Icons.add),
              label: Text(_tabController.index == 0 ? 'Loggen' : 'Notitie'),
            ),
    );
  }

  void _showAddJournalEntryDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    JournalEventType selectedType = JournalEventType.custom;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16, right: 16, top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Logboek item', style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<JournalEventType>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: JournalEventType.values.map((t) => DropdownMenuItem(
                  value: t,
                  child: Row(children: [
                    Text(t.icon),
                    const SizedBox(width: 8),
                    Text(t.label),
                  ]),
                )).toList(),
                onChanged: (v) => setModalState(() => selectedType = v!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Titel'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Beschrijving (optioneel)'),
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 24),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: titleController,
                builder: (context, value, child) {
                  return ElevatedButton(
                    onPressed: value.text.isNotEmpty 
                        ? () {
                            ref.read(journalProvider.notifier).log(
                              type: selectedType,
                              title: titleController.text,
                              description: descriptionController.text.isEmpty ? null : descriptionController.text,
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Logboek item toegevoegd')),
                            );
                          }
                        : null,
                    child: const Text('Toevoegen'),
                  );
                },
              ),
            ],
          ),
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
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: titleController,
              builder: (context, value, child) {
                return ElevatedButton(
                  onPressed: value.text.isNotEmpty 
                      ? () {
                          ref.read(notesProvider.notifier).add(
                            title: titleController.text,
                            content: contentController.text,
                          );
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text('Opslaan'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalTab extends StatelessWidget {
  final List<JournalEntry> entries;
  final VoidCallback onAdd;

  const _JournalTab({
    required this.entries,
    required this.onAdd,
  });

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
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Eerste activiteit loggen'),
            ),
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
            ...dayEntries.map((entry) => JournalEntryTile(entry: entry)),
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
        return NoteCard(
          note: note,
          onTogglePin: () => onTogglePin(note.id),
          onDelete: () => onDelete(note.id),
        );
      },
    );
  }
}
