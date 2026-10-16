import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';

// Mensimulasikan upload catatan dirty karena praktikum belum memakai backend tulis.
Future<int> syncNotes(
  NoteRepository repo, {
  Duration delay = const Duration(seconds: 1),
}) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;

  await Future<void>.delayed(delay);
  await repo.markAllSynced();
  return dirtyCount;
}

/// Menyelesaikan konflik dengan aturan last-write-wins berdasarkan [Note.updatedAt].
/// Catatan lokal menang jika waktu pembaruan kedua catatan sama.
Note resolveConflict(Note local, Note remote) {
  return local.updatedAt.compareTo(remote.updatedAt) >= 0 ? local : remote;
}
