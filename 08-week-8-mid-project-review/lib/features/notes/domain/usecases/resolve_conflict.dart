import '../entities/note.dart';

Note resolveConflict(Note local, Note remote) {
  return local.updatedAt.compareTo(remote.updatedAt) >= 0 ? local : remote;
}
