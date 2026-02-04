import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moving_tool_flutter/core/models/models.dart';
import 'package:moving_tool_flutter/features/playbook/data/repositories/playbook_repository_impl.dart';
import 'package:moving_tool_flutter/features/playbook/domain/repositories/playbook_repository.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// ============================================================================
// Repository Provider
// ============================================================================

final playbookRepositoryProvider = Provider<PlaybookRepository>((ref) {
  return PlaybookRepositoryImpl();
});

// ============================================================================
// Playbook Providers
// ============================================================================

class JournalNotifier extends Notifier<List<JournalEntry>> {
  late final PlaybookRepository repository;

  @override
  List<JournalEntry> build() {
    repository = ref.watch(playbookRepositoryProvider);
    return [];
  }

  Future<void> load() async {
    final entries = await repository.getJournalEntries();
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    state = entries;
  }

  Future<void> log({
    required JournalEventType type,
    required String title,
    String? description,
    String? userId,
    String? relatedEntityId,
  }) async {
    final entry = JournalEntry(
      id: _uuid.v4(),
      type: type,
      title: title,
      description: description,
      userId: userId,
      relatedEntityId: relatedEntityId,
      timestamp: DateTime.now(),
    );
    await repository.saveJournalEntry(entry);
    state = [entry, ...state];
  }
}

final journalProvider = NotifierProvider<JournalNotifier, List<JournalEntry>>(JournalNotifier.new);

class NotesNotifier extends Notifier<List<PlaybookNote>> {
  late final PlaybookRepository repository;

  @override
  List<PlaybookNote> build() {
    repository = ref.watch(playbookRepositoryProvider);
    return [];
  }

  Future<void> load() async {
    state = await repository.getNotes();
  }

  Future<void> add({
    required String title,
    required String content,
    String? category,
  }) async {
    final note = PlaybookNote(
      id: _uuid.v4(),
      title: title,
      content: content,
      category: category,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await repository.saveNote(note);
    state = [...state, note];
  }

  Future<void> update(PlaybookNote note) async {
    await repository.saveNote(note);
    state = state.map((n) => n.id == note.id ? note : n).toList();
  }

  Future<void> togglePin(String id) async {
    final note = state.firstWhere((n) => n.id == id);
    final updated = note.copyWith(isPinned: !note.isPinned);
    await update(updated);
  }

  Future<void> delete(String id) async {
    await repository.deleteNote(id);
    state = state.where((n) => n.id != id).toList();
  }
}

final notesProvider = NotifierProvider<NotesNotifier, List<PlaybookNote>>(NotesNotifier.new);
