import 'package:moving_tool_flutter/data/services/database_service.dart';
import 'package:moving_tool_flutter/features/playbook/domain/entities/journal_entry.dart';
import 'package:moving_tool_flutter/features/playbook/domain/entities/playbook_note.dart';
import 'package:moving_tool_flutter/features/playbook/domain/repositories/playbook_repository.dart';

class PlaybookRepositoryImpl implements PlaybookRepository {
  @override
  Future<List<JournalEntry>> getJournalEntries() async {
    return DatabaseService.getAllJournalEntries();
  }

  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {
    return DatabaseService.saveJournalEntry(entry);
  }

  @override
  Future<List<PlaybookNote>> getNotes() async {
    return DatabaseService.getAllNotes();
  }

  @override
  Future<void> saveNote(PlaybookNote note) async {
    return DatabaseService.saveNote(note);
  }

  @override
  Future<void> deleteNote(String id) async {
    return DatabaseService.deleteNote(id);
  }
}
