import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week8_mid_project_review/features/notes/presentation/pages/notes_page.dart';
import 'package:week8_mid_project_review/features/notes/presentation/providers/notes_providers.dart';

import 'support/fake_note_repository.dart';

void main() {
  testWidgets('judul kosong ditolak oleh form catatan', (tester) async {
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(FakeNoteRepository()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: NotesPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Tambah'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Tambah'));
    await tester.pumpAndSettle();

    expect(find.text('Judul wajib diisi'), findsOneWidget);
    expect(container.read(notesProvider).requireValue, isEmpty);
  });
}
