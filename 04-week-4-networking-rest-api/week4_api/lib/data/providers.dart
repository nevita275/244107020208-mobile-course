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

String friendlyErrorMessage(Object error) {
  if (error is! DioException) {
    return 'Terjadi kesalahan tak terduga: $error';
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Koneksi lambat atau timeout. Periksa internet Anda lalu coba lagi.';
    case DioExceptionType.connectionError:
      return 'Tidak dapat terhubung ke server. Periksa internet Anda.';
    case DioExceptionType.badResponse:
      final code = error.response?.statusCode;
      if (code == 404) {
        return 'Data tidak ditemukan (404).';
      }
      if (code == 401 || code == 403) {
        return 'Akses ditolak ($code). Periksa kredensial Anda.';
      }
      return 'Server bermasalah ($code). Coba lagi nanti.';
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.unknown:
      return 'Terjadi kesalahan jaringan. Coba lagi.';
  }
}
