import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'post.dart';
import 'post_repository.dart';
import 'repositories/note_repository.dart';
import 'sync.dart';

// Provider terpisah dipilih agar state offline dan posts mudah dioverride di test.
final forceOfflineProvider = NotifierProvider<ForceOfflineNotifier, bool>(
  ForceOfflineNotifier.new,
);

class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

// Hasil layar posts membedakan data cache, jaringan, dan proses refresh.
class PostsResult {
  PostsResult({
    required List<Post> posts,
    required this.fromCache,
    required this.cachedAt,
    required this.refreshing,
  }) : posts = List.unmodifiable(posts);

  final List<Post> posts;
  final bool fromCache;
  final DateTime? cachedAt;
  final bool refreshing;

  PostsResult copyWith({bool? refreshing}) {
    return PostsResult(
      posts: posts,
      fromCache: fromCache,
      cachedAt: cachedAt,
      refreshing: refreshing ?? this.refreshing,
    );
  }
}

// Provider repository mengikuti pola repository yang dipakai catatan.
final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(),
);

// AsyncNotifier memuat cache dahulu dan menyegarkannya di belakang layar.
final postsProvider = AsyncNotifierProvider<PostsNotifier, PostsResult>(
  PostsNotifier.new,
  retry: (retryCount, error) => null,
);

class PostsNotifier extends AsyncNotifier<PostsResult> {
  @override
  Future<PostsResult> build() async {
    final offline = ref.watch(forceOfflineProvider);
    final repository = ref.watch(postRepositoryProvider);
    final cached = await repository.readCached();

    if (cached.posts.isNotEmpty) {
      if (!offline) unawaited(_refreshInBackground(repository));
      return PostsResult(
        posts: cached.posts,
        fromCache: true,
        cachedAt: cached.cachedAt,
        refreshing: !offline,
      );
    }

    if (offline) {
      throw const OfflineException('Offline dan belum ada cache');
    }

    final posts = await repository.fetchRemote();
    await repository.saveCache(posts);
    return PostsResult(
      posts: posts,
      fromCache: false,
      cachedAt: DateTime.now(),
      refreshing: false,
    );
  }

  // Refresh manual mempertahankan cache jika jaringan gagal.
  Future<void> refresh() async {
    final repository = ref.read(postRepositoryProvider);
    final offline = ref.read(forceOfflineProvider);
    final previous = state.value;

    if (previous == null) {
      state = const AsyncLoading();
    } else {
      state = AsyncData(previous.copyWith(refreshing: true));
    }

    try {
      if (offline) {
        final cached = await repository.readCached();
        if (cached.posts.isEmpty) {
          throw const OfflineException('Offline dan belum ada cache');
        }
        if (!ref.mounted) return;
        state = AsyncData(
          PostsResult(
            posts: cached.posts,
            fromCache: true,
            cachedAt: cached.cachedAt,
            refreshing: false,
          ),
        );
        return;
      }

      final posts = await repository.fetchRemote();
      if (!ref.mounted) return;
      await repository.saveCache(posts);
      if (!ref.mounted) return;
      state = AsyncData(
        PostsResult(
          posts: posts,
          fromCache: false,
          cachedAt: DateTime.now(),
          refreshing: false,
        ),
      );
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      if (offline || previous == null) {
        state = AsyncError(error, stackTrace);
      } else {
        state = AsyncData(previous.copyWith(refreshing: false));
      }
    }
  }

  // Refresh background mengubah state langsung, tanpa invalidate provider.
  Future<void> _refreshInBackground(PostRepository repository) async {
    try {
      final posts = await repository.fetchRemote();
      if (!ref.mounted || ref.read(forceOfflineProvider)) return;
      await repository.saveCache(posts);
      if (!ref.mounted || ref.read(forceOfflineProvider)) return;
      state = AsyncData(
        PostsResult(
          posts: posts,
          fromCache: false,
          cachedAt: DateTime.now(),
          refreshing: false,
        ),
      );
    } catch (_) {
      if (!ref.mounted) return;
      final current = state.value;
      if (current != null) {
        state = AsyncData(current.copyWith(refreshing: false));
      }
    }
  }
}

// SyncNotifier menyimpan hasil terakhir dan mengelola state tombol sinkron.
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
        throw const OfflineException('Sedang offline, sinkronisasi ditunda');
      }

      _syncedCount = await syncNotes(ref.read(noteRepositoryProvider));
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
