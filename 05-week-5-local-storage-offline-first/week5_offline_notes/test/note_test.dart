import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';

// Fake repository mengisolasi provider dari SQLite sungguhan.
class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository({this.items = const [], this.throwError = false})
    : super(openDb: () => throw UnimplementedError());

  final List<Note> items;
  final bool throwError;
  bool updateCalled = false;
  Note? updatedNote;

  @override
  Future<List<Note>> fetchNotes() async {
    if (throwError) throw Exception('db locked (simulasi)');
    return items;
  }

  @override
  Future<Note> updateNote(Note note) async {
    updateCalled = true;
    updatedNote = Note(
      id: note.id,
      title: note.title,
      body: note.body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    return updatedNote!;
  }

  @override
  Future<int> countDirty() =>
      Future.value(items.where((note) => note.dirty).length);
}

void main() {
  test('fromMap aman terhadap field yang hilang', () {
    final note = Note.fromMap({'title': 'Belanja'});
    expect(note.title, 'Belanja');
    expect(note.body, '');
    expect(note.dirty, isFalse);
  });

  test('flag dirty bertahan pada serialisasi', () {
    final note = Note(
      title: 'a',
      updatedAt: DateTime(2026, 9, 18),
      dirty: true,
    );
    final restored = Note.fromMap(note.toMap());
    expect(restored.dirty, isTrue);
  });

  test('update menolak catatan tanpa id sebelum membuka database', () async {
    final repository = NoteRepository(
      openDb: () => throw StateError('database tidak seharusnya dibuka'),
    );
    final note = Note(title: 'Edit', updatedAt: DateTime.now());

    await expectLater(repository.updateNote(note), throwsArgumentError);
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

  test('provider error dengan repository palsu', () async {
    final container = ProviderContainer(
      retry: (count, error) => null,
      overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(throwError: true),
        ),
      ],
    );
    addTearDown(container.dispose);
    await expectLater(
      container.read(notesProvider.future),
      throwsA(isA<Exception>()),
    );
  });
}
