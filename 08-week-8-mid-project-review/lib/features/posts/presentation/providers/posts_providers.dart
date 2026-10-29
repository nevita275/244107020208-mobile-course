import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failures.dart';
import '../../../../providers/app_providers.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/usecases/refresh_posts.dart';

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepositoryImpl(),
);

final refreshPostsProvider = Provider<RefreshPosts>(
  (ref) => RefreshPosts(ref.watch(postRepositoryProvider)),
);

class PostsResult {
  PostsResult({
    required List<Post> posts,
    required this.fromCache,
    required this.cachedAt,
    required this.refreshing,
    this.refreshFailure,
  }) : posts = List.unmodifiable(posts);

  final List<Post> posts;
  final bool fromCache;
  final DateTime? cachedAt;
  final bool refreshing;
  final Failure? refreshFailure;

  PostsResult copyWith({bool? refreshing, Failure? refreshFailure}) {
    return PostsResult(
      posts: posts,
      fromCache: fromCache,
      cachedAt: cachedAt,
      refreshing: refreshing ?? this.refreshing,
      refreshFailure: refreshFailure,
    );
  }
}

final postsProvider = AsyncNotifierProvider<PostsNotifier, PostsResult>(
  PostsNotifier.new,
  retry: (retryCount, error) => null,
);

class PostsNotifier extends AsyncNotifier<PostsResult> {
  @override
  Future<PostsResult> build() async {
    final offline = ref.watch(forceOfflineProvider);
    final cached = await ref.watch(postRepositoryProvider).readCached();
    if (cached.failure != null) throw cached.failure!;

    if (cached.posts.isNotEmpty) {
      if (!offline) unawaited(_refreshInBackground());
      return PostsResult(
        posts: cached.posts,
        fromCache: true,
        cachedAt: cached.cachedAt,
        refreshing: !offline,
      );
    }

    if (offline) {
      throw const NetworkFailure('Offline dan belum ada cache.');
    }

    final refreshed = await ref.watch(refreshPostsProvider).call();
    if (refreshed.failure != null) throw refreshed.failure!;
    return PostsResult(
      posts: refreshed.posts,
      fromCache: false,
      cachedAt: DateTime.now(),
      refreshing: false,
    );
  }

  Future<void> refresh() async {
    final offline = ref.read(forceOfflineProvider);
    final previous = state.value;
    if (previous == null) {
      state = const AsyncLoading();
    } else {
      state = AsyncData(previous.copyWith(refreshing: true));
    }

    if (offline) {
      final cached = await ref.read(postRepositoryProvider).readCached();
      if (!ref.mounted) return;
      if (cached.failure != null) {
        state = AsyncError(cached.failure!, StackTrace.current);
      } else if (cached.posts.isEmpty) {
        state = const AsyncError(
          NetworkFailure('Offline dan belum ada cache.'),
          StackTrace.empty,
        );
      } else {
        state = AsyncData(
          PostsResult(
            posts: cached.posts,
            fromCache: true,
            cachedAt: cached.cachedAt,
            refreshing: false,
          ),
        );
      }
      return;
    }

    final refreshed = await ref.read(refreshPostsProvider).call();
    if (!ref.mounted) return;
    final failure = refreshed.failure;
    if (failure != null) {
      if (previous == null) {
        state = AsyncError(failure, StackTrace.current);
      } else {
        state = AsyncData(
          previous.copyWith(refreshing: false, refreshFailure: failure),
        );
      }
      return;
    }
    state = AsyncData(
      PostsResult(
        posts: refreshed.posts,
        fromCache: false,
        cachedAt: DateTime.now(),
        refreshing: false,
      ),
    );
  }

  Future<void> _refreshInBackground() async {
    final refreshed = await ref.read(refreshPostsProvider).call();
    if (!ref.mounted || ref.read(forceOfflineProvider)) return;
    final current = state.value;
    if (current == null) return;

    final failure = refreshed.failure;
    if (failure != null) {
      state = AsyncData(
        current.copyWith(refreshing: false, refreshFailure: failure),
      );
      return;
    }
    state = AsyncData(
      PostsResult(
        posts: refreshed.posts,
        fromCache: false,
        cachedAt: DateTime.now(),
        refreshing: false,
      ),
    );
  }
}
