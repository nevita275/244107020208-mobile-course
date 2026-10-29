import 'package:flutter_test/flutter_test.dart';
import 'package:week8_mid_project_review/core/failures.dart';
import 'package:week8_mid_project_review/features/notes/domain/entities/note.dart';
import 'package:week8_mid_project_review/features/notes/domain/usecases/resolve_conflict.dart';
import 'package:week8_mid_project_review/features/notes/domain/usecases/sync_notes.dart';

import 'support/fake_note_repository.dart';

void main() {
  test('SyncNotes menandai semua catatan dirty sebagai tersinkron', () async {
    final repository = FakeNoteRepository(dirtyCount: 3);

    final result = await SyncNotes(repository, delay: Duration.zero).call();

    expect(result.count, 3);
    expect(result.failure, isNull);
    expect(repository.markAllSyncedCalls, 1);
    expect((await repository.countDirty()).count, 0);
  });

  test('SyncNotes tanpa catatan dirty tidak menandai apa pun', () async {
    final repository = FakeNoteRepository(dirtyCount: 0);

    final result = await SyncNotes(repository, delay: Duration.zero).call();

    expect(result.count, 0);
    expect(result.failure, isNull);
    expect(repository.markAllSyncedCalls, 0);
  });

  test('SyncNotes meneruskan kegagalan repository', () async {
    final result = await SyncNotes(
      FakeNoteRepository(operationFailure: const LocalFailure('db locked')),
      delay: Duration.zero,
    ).call();

    expect(result.count, 0);
    expect(result.failure, isA<LocalFailure>());
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
