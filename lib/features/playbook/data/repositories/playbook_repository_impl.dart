import 'package:flutter/foundation.dart';
import 'package:moving_tool_flutter/core/error/exceptions.dart';
import 'package:moving_tool_flutter/data/services/database_service.dart';
import 'package:moving_tool_flutter/features/playbook/domain/entities/journal_entry.dart';
import 'package:moving_tool_flutter/features/playbook/domain/entities/playbook_note.dart';
import 'package:moving_tool_flutter/features/playbook/domain/repositories/playbook_repository.dart';

class PlaybookRepositoryImpl implements PlaybookRepository {
  @override
  Future<List<JournalEntry>> getJournalEntries() async {
    try {
      return DatabaseService.getAllJournalEntries();
    } catch (e) {
      debugPrint('Error getting journal entries: $e');
      throw FetchFailure('Failed to load journal entries', e);
    }
  }

  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {
    try {
      await DatabaseService.saveJournalEntry(entry);
    } catch (e) {
      debugPrint('Error saving journal entry: $e');
      throw SaveFailure('Failed to save journal entry', e);
    }
  }

  @override
  Future<List<PlaybookNote>> getNotes() async {
    try {
      return DatabaseService.getAllNotes();
    } catch (e) {
      debugPrint('Error getting notes: $e');
      throw FetchFailure('Failed to load notes', e);
    }
  }

  @override
  Future<void> saveNote(PlaybookNote note) async {
    try {
      try {
        await DatabaseService.saveNote(note);
      } catch (e) {
        debugPrint('Error saving note: $e');
        throw SaveFailure('Failed to save note', e);
      }
    } catch (e) {
       // outer catch just in case, mirroring style
       debugPrint('Error saving note (outer): $e');
       throw SaveFailure('Failed to save note', e);
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      await DatabaseService.deleteNote(id);
    } catch (e) {
      debugPrint('Error deleting note: $e');
      throw DeleteFailure('Failed to delete note', e);
    }
  }
}
