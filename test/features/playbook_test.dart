
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moving_tool_flutter/core/models/models.dart';
import 'package:moving_tool_flutter/data/providers/providers.dart';
import 'package:moving_tool_flutter/features/playbook/domain/repositories/playbook_repository.dart';
import 'package:moving_tool_flutter/features/playbook/playbook_screen.dart';
import 'package:moving_tool_flutter/features/playbook/presentation/providers/playbook_providers.dart'; // Import directly to be safe

class MockPlaybookRepository implements PlaybookRepository {
  @override
  Future<List<JournalEntry>> getJournalEntries() async => [];

  @override
  Future<List<PlaybookNote>> getNotes() async => [];

  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {}

  @override
  Future<void> saveNote(PlaybookNote note) async {}

  @override
  Future<void> deleteNote(String id) async {}
}

// Fake Notifier to mock Hive interactions
class FakeNotesNotifier extends NotesNotifier {
  final List<PlaybookNote> _initial;
  FakeNotesNotifier([List<PlaybookNote>? initialNotes]) : _initial = initialNotes ?? [];

  @override
  List<PlaybookNote> build() => _initial;

  @override
  Future<void> load() async {
    // No-op for test
  }

  @override
  Future<void> add({required String title, required String content, String? category}) async {
    final note = PlaybookNote(
      id: 'test-id-${state.length}', 
      title: title, 
      content: content, 
      category: category,
      createdAt: DateTime.now(), 
      updatedAt: DateTime.now()
    );
    state = [...state, note];
  }
}

void main() {
  testWidgets('PlaybookScreen shows placeholder when empty', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PlaybookScreen(),
        ),
      ),
    );

    // Default tab is Journal 'Dagboek'
    expect(find.text('Nog geen activiteit'), findsOneWidget);

    // Switch to Notes tab
    await tester.tap(find.text('Notities'));
    await tester.pumpAndSettle();

    expect(find.text('Nog geen notities'), findsOneWidget);
  });

  testWidgets('Can add a note in PlaybookScreen', (WidgetTester tester) async {
     await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notesProvider.overrideWith(() => FakeNotesNotifier()),
        ],
        child: const MaterialApp(
          home: PlaybookScreen(),
        ),
      ),
    );

    // Switch to Notes tab
    await tester.tap(find.text('Notities'));
    await tester.pumpAndSettle();

    // Tap FAB (or empty state button)
    await tester.tap(find.text('Eerste notitie'));
    await tester.pumpAndSettle();

    // Check dialog open
    expect(find.text('Nieuwe notitie'), findsOneWidget);
    
    // Check validation: Button disabled initially
    final saveFinder = find.text('Opslaan');
    final button = tester.widget<ElevatedButton>(find.ancestor(of: saveFinder, matching: find.byType(ElevatedButton)));
    expect(button.onPressed, isNull);

    // Enter title
    await tester.enterText(find.byType(TextField).first, 'My Test Note');
    await tester.pump(); // Rebuild for ValueListenable

    // Check validation: Button enabled
    final buttonEnabled = tester.widget<ElevatedButton>(find.ancestor(of: saveFinder, matching: find.byType(ElevatedButton)));
    expect(buttonEnabled.onPressed, isNotNull);

    // Save
    await tester.tap(saveFinder);
    await tester.pumpAndSettle();

    // Verify Note appears
    expect(find.text('My Test Note'), findsOneWidget);
  });
}
