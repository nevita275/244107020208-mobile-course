import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/data/sync.dart';

// Fake repository hanya menyediakan operasi yang dipakai syncNotes.
class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository({required this.dirtyCount})
    : super(openDb: () => throw UnimplementedError());

  int dirtyCount;
  int markAllSyncedCalls = 0;

  @override
  Future<int> countDirty() async => dirtyCount;

  @override
  Future<void> markAllSynced() async {
    markAllSyncedCalls++;
    dirtyCount = 0;
  }
}

void main() {
  test('syncNotes menandai semua catatan dirty sebagai tersinkron', () async {
    final repository = FakeNoteRepository(dirtyCount: 3);

    final synced = await syncNotes(repository, delay: Duration.zero);

    expect(synced, 3);
    expect(repository.markAllSyncedCalls, 1);
    expect(await repository.countDirty(), 0);
  });

  test('syncNotes tanpa catatan dirty tidak menandai apa pun', () async {
    final repository = FakeNoteRepository(dirtyCount: 0);

    final synced = await syncNotes(repository, delay: Duration.zero);

    expect(synced, 0);
    expect(repository.markAllSyncedCalls, 0);
  });

  test('resolveConflict memilih catatan dengan updatedAt lebih baru', () {
    final local = Note(title: 'lokal', updatedAt: DateTime(2026, 10, 1));
    final remote = Note(title: 'remote', updatedAt: DateTime(2026, 10, 2));

    expect(resolveConflict(local, remote), same(remote));
    expect(resolveConflict(remote, local), same(remote));
  });

  test('resolveConflict memilih lokal bila updatedAt sama', () {
    final updatedAt = DateTime(2026, 10, 1);
    final local = Note(title: 'lokal', updatedAt: updatedAt);
    final remote = Note(title: 'remote', updatedAt: updatedAt);

    expect(resolveConflict(local, remote), same(local));
  });
}
