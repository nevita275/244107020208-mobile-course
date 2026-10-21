import 'package:sqflite/sqflite.dart';

import '../../../../core/failures.dart';
import '../../../../data/local/db.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl({Future<Database> Function()? openDb})
    : _openDb = openDb ?? openNotesDb;

  final Future<Database> Function() _openDb;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    try {
      final db = await _openDb();
      final rows = await db.query('notes', orderBy: 'updated_at DESC');
      final notes = rows
          .map((row) => NoteModel.fromMap(row).toEntity())
          .toList();
      return (notes: notes, failure: null);
    } on Exception {
      return (
        notes: const <Note>[],
        failure: const LocalFailure('Catatan tidak dapat dibaca.'),
      );
    }
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    try {
      final db = await _openDb();
      final note = NoteModel(
        title: title,
        body: body,
        updatedAt: DateTime.now(),
        dirty: true,
      );
      final id = await db.insert('notes', note.toMap());
      return (
        note: NoteModel(
          id: id,
          title: note.title,
          body: note.body,
          updatedAt: note.updatedAt,
          dirty: note.dirty,
        ).toEntity(),
        failure: null,
      );
    } on Exception {
      return (
        note: null,
        failure: const LocalFailure('Catatan tidak dapat disimpan.'),
      );
    }
  }

  @override
  Future<({Note? note, Failure? failure})> updateNote(Note note) async {
    final id = note.id;
    if (id == null) {
      return (
        note: null,
        failure: const LocalFailure('Catatan tidak memiliki ID yang valid.'),
      );
    }

    try {
      final updatedNote = NoteModel(
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
        return (
          note: null,
          failure: const LocalFailure('Catatan tidak ditemukan.'),
        );
      }
      return (note: updatedNote.toEntity(), failure: null);
    } on Exception {
      return (
        note: null,
        failure: const LocalFailure('Catatan tidak dapat diperbarui.'),
      );
    }
  }

  @override
  Future<Failure?> deleteNote(int id) async {
    try {
      final db = await _openDb();
      await db.delete('notes', where: 'id = ?', whereArgs: [id]);
      return null;
    } on Exception {
      return const LocalFailure('Catatan tidak dapat dihapus.');
    }
  }

  @override
  Future<({int count, Failure? failure})> countDirty() async {
    try {
      final db = await _openDb();
      final rows = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM notes WHERE dirty = 1',
      );
      return (count: (rows.first['c'] as num?)?.toInt() ?? 0, failure: null);
    } on Exception {
      return (
        count: 0,
        failure: const LocalFailure('Status sinkronisasi tidak dapat dibaca.'),
      );
    }
  }

  @override
  Future<Failure?> markAllSynced() async {
    try {
      final db = await _openDb();
      await db.update('notes', {'dirty': 0}, where: 'dirty = 1');
      return null;
    } on Exception {
      return const LocalFailure('Catatan tidak dapat ditandai tersinkron.');
    }
  }
}
