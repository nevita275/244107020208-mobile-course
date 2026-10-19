import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../local/db.dart';
import '../local/note.dart';

// Repository menjadi satu-satunya pintu baca dan tulis tabel catatan.
class NoteRepository {
  NoteRepository({Future<Database> Function()? openDb})
    : _openDb = openDb ?? openNotesDb;

  final Future<Database> Function() _openDb;

  Future<List<Note>> fetchNotes() async {
    final db = await _openDb();
    final rows = await db.query('notes', orderBy: 'updated_at DESC');
    return rows.map(Note.fromMap).toList();
  }

  Future<Note> addNote({required String title, String body = ''}) async {
    final db = await _openDb();
    final note = Note(
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    final id = await db.insert('notes', note.toMap());
    return Note(
      id: id,
      title: note.title,
      body: note.body,
      updatedAt: note.updatedAt,
      dirty: true,
    );
  }

  Future<void> deleteNote(int id) async {
    final db = await _openDb();
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<Note> updateNote(Note note) async {
    final id = note.id;
    if (id == null) {
      throw ArgumentError.value(id, 'note.id', 'Catatan harus memiliki id');
    }

    final updatedNote = Note(
      id: id,
      title: note.title,
      body: note.body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    final db = await _openDb();
    final updatedRows = await db.update(
      'notes',
      updatedNote.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
    if (updatedRows == 0) {
      throw StateError('Catatan dengan id $id tidak ditemukan');
    }
    return updatedNote;
  }

  Future<int> countDirty() async {
    final db = await _openDb();
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM notes WHERE dirty = 1',
    );
    return (rows.first['c'] as num?)?.toInt() ?? 0;
  }

  Future<void> markAllSynced() async {
    final db = await _openDb();
    await db.update('notes', {'dirty': 0}, where: 'dirty = 1');
  }
}

// Provider menyediakan repository yang sama untuk UI dan pengujian.
final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepository(),
);

// Provider async memuat daftar catatan dari database lokal.
final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() {
    return ref.watch(noteRepositoryProvider).fetchNotes();
  }

  // Tambah catatan baru ke state tanpa mengubah list sebelumnya.
  Future<void> add(String title, String body) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(noteRepositoryProvider);
      final note = await repository.addNote(title: title, body: body);
      ref.invalidate(dirtyCountProvider);
      return [note, ...(state.value ?? const <Note>[])];
    });
  }

  Future<void> updateNote(Note note) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(noteRepositoryProvider);
      final updatedNote = await repository.updateNote(note);
      ref.invalidate(dirtyCountProvider);
      final updatedNotes =
          (state.value ?? const <Note>[])
              .map(
                (current) =>
                    current.id == updatedNote.id ? updatedNote : current,
              )
              .toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return updatedNotes;
    });
  }

  // Hapus catatan, lalu perbarui list dan jumlah catatan dirty.
  Future<void> remove(int id) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(noteRepositoryProvider);
      await repository.deleteNote(id);
      ref.invalidate(dirtyCountProvider);
      return (state.value ?? const <Note>[])
          .where((note) => note.id != id)
          .toList();
    });
  }
}

// Provider terpisah agar badge dapat memuat jumlah dirty secara mandiri.
final dirtyCountProvider = FutureProvider<int>((ref) {
  return ref.watch(noteRepositoryProvider).countDirty();
});
