import '../../../../core/failures.dart';
import '../repositories/note_repository.dart';

class SyncNotes {
  const SyncNotes(this._repository, {this.delay = const Duration(seconds: 1)});

  final NoteRepository _repository;
  final Duration delay;

  Future<({int count, Failure? failure})> call() async {
    final dirty = await _repository.countDirty();
    if (dirty.failure != null) return (count: 0, failure: dirty.failure);
    if (dirty.count == 0) return (count: 0, failure: null);

    await Future<void>.delayed(delay);
    final failure = await _repository.markAllSynced();
    if (failure != null) return (count: 0, failure: failure);
    return (count: dirty.count, failure: null);
  }
}
