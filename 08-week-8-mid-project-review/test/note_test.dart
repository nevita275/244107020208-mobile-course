import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week8_mid_project_review/core/failures.dart';
import 'package:week8_mid_project_review/features/notes/data/models/note_model.dart';
import 'package:week8_mid_project_review/features/notes/domain/entities/note.dart';
import 'package:week8_mid_project_review/features/notes/domain/usecases/get_notes.dart';
import 'package:week8_mid_project_review/features/notes/presentation/providers/notes_providers.dart';

import 'support/fake_note_repository.dart';

void main() {
  test('NoteModel aman terhadap field yang hilang', () {
    final note = NoteModel.fromMap({'title': 'Belanja'});
    expect(note.title, 'Belanja');
    expect(note.body, '');
    expect(note.dirty, isFalse);
  });

  test('flag dirty bertahan pada serialisasi', () {
    final note = NoteModel(
      title: 'a',
      updatedAt: DateTime(2026, 9, 18),
      dirty: true,
    );
    final restored = NoteModel.fromMap(note.toMap());
    expect(restored.dirty, isTrue);
  });

  test('GetNotes meneruskan daftar dari repository palsu', () async {
    final note = Note(title: 'Tes', updatedAt: DateTime(2026, 9, 27));
    final result = await GetNotes(FakeNoteRepository(items: [note])).call();

    expect(result.failure, isNull);
    expect(result.notes, [note]);
  });

  test('GetNotes meneruskan failure tanpa melempar', () async {
    final result = await GetNotes(
      FakeNoteRepository(fetchFailure: const LocalFailure('db locked')),
    ).call();

    expect(result.failure, isA<LocalFailure>());
    expect(result.notes, isEmpty);
  });

  test('provider sukses dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(
            items: [Note(title: 'Tes', updatedAt: DateTime.now())],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    final notes = await container.read(notesProvider.future);
    expect(notes.length, 1);
    expect(notes.first.title, 'Tes');
  });

  test('notifier memperbarui catatan lewat repository palsu', () async {
    final initialNote = Note(
      id: 1,
      title: 'Judul lama',
      body: 'Isi lama',
      updatedAt: DateTime(2026, 9, 18),
    );
    final fakeRepository = FakeNoteRepository(items: [initialNote]);
    final container = ProviderContainer(
      overrides: [noteRepositoryProvider.overrideWithValue(fakeRepository)],
    );
    addTearDown(container.dispose);

    await container.read(notesProvider.future);
    await container
        .read(notesProvider.notifier)
        .updateNote(
          Note(
            id: initialNote.id,
            title: 'Judul baru',
            body: 'Isi baru',
            updatedAt: initialNote.updatedAt,
          ),
        );

    final updatedNotes = container.read(notesProvider).requireValue;
    expect(fakeRepository.updateCalled, isTrue);
    expect(updatedNotes.single.title, 'Judul baru');
    expect(updatedNotes.single.body, 'Isi baru');
    expect(updatedNotes.single.dirty, isTrue);
  });

  test('provider menampilkan failure repository secara eksplisit', () async {
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(
            fetchFailure: const LocalFailure('Catatan gagal dimuat.'),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await expectLater(
      container.read(notesProvider.future),
      throwsA(
        isA<LocalFailure>().having(
          (failure) => failure.message,
          'message',
          'Catatan gagal dimuat.',
        ),
      ),
    );
  });
}
