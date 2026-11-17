import 'package:week8_mid_project_review/core/failures.dart';
import 'package:week8_mid_project_review/features/notes/domain/entities/note.dart';
import 'package:week8_mid_project_review/features/notes/domain/repositories/note_repository.dart';

class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({
    List<Note> items = const [],
    this.fetchFailure,
    this.operationFailure,
    this.addFailure,
    this.updateFailure,
    this.deleteFailure,
    this.dirtyCount,
  }) : items = List.of(items);

  final List<Note> items;
  final Failure? fetchFailure;
  final Failure? operationFailure;
  final Failure? addFailure;
  final Failure? updateFailure;
  final Failure? deleteFailure;
  int? dirtyCount;
  int _nextId = 1;
  bool updateCalled = false;
  int addCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;
  Note? updatedNote;
  int markAllSyncedCalls = 0;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    if (fetchFailure != null) {
      return (notes: const <Note>[], failure: fetchFailure);
    }
    return (notes: List<Note>.unmodifiable(items), failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    addCalls++;
    final failure = addFailure ?? operationFailure;
    if (failure != null) {
      return (note: null, failure: failure);
    }
    final note = Note(
      id: _nextId++,
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    items.insert(0, note);
    return (note: note, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> updateNote(Note note) async {
    updateCalled = true;
    updateCalls++;
    final failure = updateFailure ?? operationFailure;
    if (failure != null) {
      return (note: null, failure: failure);
    }
    updatedNote = Note(
      id: note.id,
      title: note.title,
      body: note.body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    final index = items.indexWhere((item) => item.id == note.id);
    if (index >= 0) items[index] = updatedNote!;
    return (note: updatedNote, failure: null);
  }

  @override
  Future<Failure?> deleteNote(int id) async {
    deleteCalls++;
    final failure = deleteFailure ?? operationFailure;
    if (failure != null) return failure;
    items.removeWhere((note) => note.id == id);
    return null;
  }

  @override
  Future<({int count, Failure? failure})> countDirty() async {
    if (operationFailure != null) {
      return (count: 0, failure: operationFailure);
    }
    return (
      count: dirtyCount ?? items.where((note) => note.dirty).length,
      failure: null,
    );
  }

  @override
  Future<Failure?> markAllSynced() async {
    if (operationFailure != null) return operationFailure;
    markAllSyncedCalls++;
    dirtyCount = 0;
    for (var index = 0; index < items.length; index++) {
      final note = items[index];
      items[index] = Note(
        id: note.id,
        title: note.title,
        body: note.body,
        updatedAt: note.updatedAt,
      );
    }
    return null;
  }
}
