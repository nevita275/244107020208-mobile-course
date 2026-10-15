import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'models/post.dart';
import 'repositories/post_repository.dart';

final dioProvider = Provider<Dio>((ref) => createDio());

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(dioProvider)),
);

final postDetailProvider = FutureProvider.family<Post, int>(
  (ref, id) => ref.watch(postRepositoryProvider).fetchPost(id),
);

class PostListNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() {
    final repository = ref.watch(postRepositoryProvider);
    return repository.fetchPosts();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final repository = ref.read(postRepositoryProvider);
    try {
      state = AsyncData(await repository.fetchPosts());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

// Retry otomatis Riverpod 3 dinonaktifkan agar error langsung final dan mudah diuji.
final postListProvider = AsyncNotifierProvider<PostListNotifier, List<Post>>(
  PostListNotifier.new,
  retry: (retryCount, error) => null,
);

Future<List<Post>> readPostsOnce(ProviderContainer container) {
  final completer = Completer<List<Post>>();
  final subscription = container.listen(postListProvider, (previous, next) {
    if (next.isLoading) return;
    next.when(
      data: completer.complete,
      error: completer.completeError,
      loading: () {},
    );
  }, fireImmediately: true);
  return completer.future.whenComplete(subscription.close);
}

Future<Object?> readPostsErrorOnce(ProviderContainer container) {
  final completer = Completer<Object?>();
  final subscription = container.listen(postListProvider, (previous, next) {
    if (next.isLoading) return;
    completer.complete(next.error);
  }, fireImmediately: true);
  return completer.future.whenComplete(subscription.close);
}
