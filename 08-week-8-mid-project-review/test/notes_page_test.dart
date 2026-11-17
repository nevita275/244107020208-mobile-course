import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week8_mid_project_review/core/failures.dart';
import 'package:week8_mid_project_review/features/notes/domain/entities/note.dart';
import 'package:week8_mid_project_review/features/notes/presentation/pages/notes_page.dart';
import 'package:week8_mid_project_review/features/notes/presentation/providers/notes_providers.dart';

import 'support/fake_note_repository.dart';

void main() {
  testWidgets('judul kosong ditolak oleh form catatan', (tester) async {
    final repository = FakeNoteRepository();
    final container = await _pumpNotesPage(tester, repository);

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Tambah'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Tambah'));
    await tester.pumpAndSettle();

    expect(find.text('Judul wajib diisi'), findsOneWidget);
    expect(container.read(notesProvider).requireValue, isEmpty);
    expect(repository.addCalls, 0);
  });

  testWidgets('judul yang hanya berisi spasi ditolak oleh form catatan', (
    tester,
  ) async {
    final repository = FakeNoteRepository();
    final container = await _pumpNotesPage(tester, repository);

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Tambah'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.tap(find.widgetWithText(FilledButton, 'Tambah'));
    await tester.pumpAndSettle();

    expect(find.text('Judul wajib diisi'), findsOneWidget);
    expect(container.read(notesProvider).requireValue, isEmpty);
    expect(repository.addCalls, 0);
  });

  testWidgets(
    'gagal menambah catatan mempertahankan daftar dan menampilkan pesan',
    (tester) async {
      final note = _existingNote();
      const failureMessage = 'Database tidak dapat menyimpan catatan.';
      final repository = FakeNoteRepository(
        items: [note],
        addFailure: const LocalFailure(failureMessage),
      );
      final container = await _pumpNotesPage(tester, repository);

      await tester.tap(find.widgetWithText(FloatingActionButton, 'Tambah'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Catatan baru');
      await tester.tap(find.widgetWithText(FilledButton, 'Tambah'));
      await tester.pumpAndSettle();

      expect(find.text(note.title), findsOneWidget);
      expect(find.text(failureMessage), findsOneWidget);
      expect(container.read(notesProvider).requireValue, [note]);
      expect(repository.addCalls, 1);
    },
  );

  testWidgets(
    'gagal mengubah catatan mempertahankan daftar dan menampilkan pesan',
    (tester) async {
      final note = _existingNote();
      const failureMessage = 'Database tidak dapat memperbarui catatan.';
      final repository = FakeNoteRepository(
        items: [note],
        updateFailure: const LocalFailure(failureMessage),
      );
      final container = await _pumpNotesPage(tester, repository);

      await tester.tap(find.text(note.title));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Judul baru');
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await tester.pumpAndSettle();

      expect(find.text(note.title), findsOneWidget);
      expect(find.text('Judul baru'), findsNothing);
      expect(find.text(failureMessage), findsOneWidget);
      expect(container.read(notesProvider).requireValue, [note]);
      expect(repository.updateCalls, 1);
    },
  );

  testWidgets(
    'gagal menghapus catatan mempertahankan daftar dan menampilkan pesan',
    (tester) async {
      final note = _existingNote();
      const failureMessage = 'Database tidak dapat menghapus catatan.';
      final repository = FakeNoteRepository(
        items: [note],
        deleteFailure: const LocalFailure(failureMessage),
      );
      final container = await _pumpNotesPage(tester, repository);

      await tester.tap(find.byTooltip('Hapus catatan'));
      await tester.pumpAndSettle();

      expect(find.text(note.title), findsOneWidget);
      expect(find.text(failureMessage), findsOneWidget);
      expect(container.read(notesProvider).requireValue, [note]);
      expect(repository.deleteCalls, 1);
    },
  );
}

Future<ProviderContainer> _pumpNotesPage(
  WidgetTester tester,
  FakeNoteRepository repository,
) async {
  final container = ProviderContainer(
    overrides: [noteRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: NotesPage()),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Note _existingNote() => Note(
  id: 1,
  title: 'Catatan tersimpan',
  body: 'Isi sebelumnya',
  updatedAt: DateTime(2026, 9, 18),
);
