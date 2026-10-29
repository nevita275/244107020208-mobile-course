import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failures.dart';
import '../../../../data/local/db.dart';
import '../../../../providers/app_providers.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/sync_notes.dart';

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepositoryImpl(openDb: openNotesDb),
);

final getNotesProvider = Provider<GetNotes>(
  (ref) => GetNotes(ref.watch(noteRepositoryProvider)),
);

final syncNotesProvider = Provider<SyncNotes>(
  (ref) => SyncNotes(ref.watch(noteRepositoryProvider)),
);

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
  retry: (retryCount, error) => null,
);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final result = await ref.watch(getNotesProvider).call();
    if (result.failure case final failure?) throw failure;
    return result.notes;
  }

  Future<void> add(String title, String body) async {
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(noteRepositoryProvider)
          .addNote(title: title, body: body);
      if (result.failure case final failure?) throw failure;
      final note = result.note;
      if (note == null) {
        throw const LocalFailure('Catatan tidak dapat disimpan.');
      }
      ref.invalidate(dirtyCountProvider);
      return [note, ...(state.value ?? const <Note>[])];
    });
  }

  Future<void> updateNote(Note note) async {
    state = await AsyncValue.guard(() async {
      final result = await ref.read(noteRepositoryProvider).updateNote(note);
      if (result.failure case final failure?) throw failure;
      final updatedNote = result.note;
      if (updatedNote == null) {
        throw const LocalFailure('Catatan tidak dapat diperbarui.');
      }
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

  Future<void> remove(int id) async {
    state = await AsyncValue.guard(() async {
      final failure = await ref.read(noteRepositoryProvider).deleteNote(id);
      if (failure != null) throw failure;
      ref.invalidate(dirtyCountProvider);
      return (state.value ?? const <Note>[])
          .where((note) => note.id != id)
          .toList();
    });
  }
}

final dirtyCountProvider = FutureProvider<int>((ref) async {
  final result = await ref.watch(noteRepositoryProvider).countDirty();
  if (result.failure case final failure?) throw failure;
  return result.count;
}, retry: (retryCount, error) => null);

final syncControllerProvider = AsyncNotifierProvider<SyncController, void>(
  SyncController.new,
);

class SyncController extends AsyncNotifier<void> {
  int? _syncedCount;

  int? get syncedCount => _syncedCount;

  @override
  Future<void> build() async {}

  Future<int> sync() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (ref.read(forceOfflineProvider)) {
        throw const NetworkFailure('Sedang offline, sinkronisasi ditunda');
      }

      final result = await ref.read(syncNotesProvider).call();
      if (result.failure case final failure?) throw failure;
      _syncedCount = result.count;
      ref.invalidate(dirtyCountProvider);
      ref.invalidate(notesProvider);
    });

    final error = state.error;
    if (error != null) {
      Error.throwWithStackTrace(error, state.stackTrace!);
    }
    return _syncedCount ?? 0;
  }
}
