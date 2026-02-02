import 'package:moving_tool_flutter/features/playbook/domain/entities/journal_entry.dart';
import 'package:moving_tool_flutter/features/playbook/domain/entities/playbook_note.dart';

abstract class PlaybookRepository {
  // Journal
  Future<List<JournalEntry>> getJournalEntries();
  Future<void> saveJournalEntry(JournalEntry entry);

  // Notes
  Future<List<PlaybookNote>> getNotes();
  Future<void> saveNote(PlaybookNote note);
  Future<void> deleteNote(String id);
}
