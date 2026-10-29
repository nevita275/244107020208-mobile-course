import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week8_mid_project_review/core/failures.dart';
import 'package:week8_mid_project_review/features/posts/domain/entities/post.dart';
import 'package:week8_mid_project_review/features/posts/domain/repositories/post_repository.dart';
import 'package:week8_mid_project_review/features/posts/presentation/providers/posts_providers.dart';
import 'package:week8_mid_project_review/providers/app_providers.dart';

// Fake repository menyuplai cache/remote tanpa SQLite atau koneksi jaringan.
class FakePostRepository implements PostRepository {
  FakePostRepository({
    required this.cachedPosts,
    this.cachedAt,
    this.remotePosts = const [],
    this.remoteResult,
    this.remoteFailure,
    this.saveFailure,
  });

  List<Post> cachedPosts;
  DateTime? cachedAt;
  final List<Post> remotePosts;
  final Failure? remoteFailure;
  final Failure? saveFailure;
  final Completer<List<Post>>? remoteResult;
  int fetchRemoteCalls = 0;
  int saveCacheCalls = 0;

  @override
  Future<({List<Post> posts, DateTime? cachedAt, Failure? failure})>
  readCached() async {
    return (posts: cachedPosts, cachedAt: cachedAt, failure: null);
  }

  @override
  Future<({List<Post> posts, Failure? failure})> fetchRemote() async {
    fetchRemoteCalls++;
    if (remoteResult != null) {
      return (posts: await remoteResult!.future, failure: remoteFailure);
    }
    return (posts: remotePosts, failure: remoteFailure);
  }

  @override
  Future<Failure?> saveCache(List<Post> posts) async {
    saveCacheCalls++;
    if (saveFailure != null) return saveFailure;
    cachedPosts = posts;
    cachedAt = DateTime.now();
    return null;
  }
}

void main() {
  test(
    'postsProvider mengambil dan menyimpan data remote tanpa cache',
    () async {
      final remotePost = Post(
        userId: 1,
        id: 2,
        title: 'Remote',
        body: 'Dari server',
      );
      final repository = FakePostRepository(
        cachedPosts: [],
        remotePosts: [remotePost],
      );
      final container = ProviderContainer(
        overrides: [postRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final result = await container.read(postsProvider.future);

      expect(result.fromCache, isFalse);
      expect(result.posts.single.title, 'Remote');
      expect(repository.fetchRemoteCalls, 1);
      expect(repository.saveCacheCalls, 1);
      expect(repository.cachedPosts.single, same(remotePost));
    },
  );

  test('postsProvider menampilkan cache tanpa menunggu remote', () async {
    final remoteResult = Completer<List<Post>>();
    final cachedPost = Post(
      userId: 1,
      id: 1,
      title: 'Cache',
      body: 'Tersimpan lokal',
    );
    final repository = FakePostRepository(
      cachedPosts: [cachedPost],
      cachedAt: DateTime(2026, 10, 1),
      remoteResult: remoteResult,
    );
    final container = ProviderContainer(
      overrides: [postRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(() {
      container.dispose();
      if (!remoteResult.isCompleted) remoteResult.complete(const []);
    });

    final result = await container.read(postsProvider.future);

    expect(result.fromCache, isTrue);
    expect(result.posts.single.title, 'Cache');
    expect(repository.fetchRemoteCalls, 1);
    expect(remoteResult.isCompleted, isFalse);
  });

  test('forceOffline dan cache kosong menghasilkan error', () async {
    final repository = FakePostRepository(cachedPosts: []);
    final container = ProviderContainer(
      retry: (count, error) => null,
      overrides: [postRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.read(forceOfflineProvider.notifier).toggle();

    await expectLater(
      container.read(postsProvider.future),
      throwsA(isA<NetworkFailure>()),
    );
    expect(repository.fetchRemoteCalls, 0);
  });

  test('forceOffline memakai cache tanpa meminta remote', () async {
    final cachedPost = Post(
      userId: 2,
      id: 7,
      title: 'Tetap tersedia',
      body: 'Cache lokal',
    );
    final repository = FakePostRepository(
      cachedPosts: [cachedPost],
      cachedAt: DateTime(2026, 10, 1),
    );
    final container = ProviderContainer(
      overrides: [postRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.read(forceOfflineProvider.notifier).toggle();

    final result = await container.read(postsProvider.future);

    expect(result.fromCache, isTrue);
    expect(result.posts.single.title, 'Tetap tersedia');
    expect(repository.fetchRemoteCalls, 0);
  });

  test('refresh gagal mempertahankan cache dan menyampaikan failure', () async {
    final cachedPost = Post(
      userId: 1,
      id: 1,
      title: 'Cache lama',
      body: 'Masih tersedia',
    );
    final repository = FakePostRepository(
      cachedPosts: [cachedPost],
      remoteFailure: const NetworkFailure('Server tidak tersedia.'),
    );
    final container = ProviderContainer(
      overrides: [postRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(postsProvider.future);
    await container.read(postsProvider.notifier).refresh();

    final result = container.read(postsProvider).requireValue;
    expect(result.posts.single.title, 'Cache lama');
    expect(result.refreshFailure?.message, 'Server tidak tersedia.');
  });
}
