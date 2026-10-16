import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/post.dart';
import 'package:week5_offline_notes/data/post_repository.dart';
import 'package:week5_offline_notes/data/providers.dart';

// Fake repository menyuplai cache/remote tanpa SQLite atau koneksi jaringan.
class FakePostRepository extends PostRepository {
  FakePostRepository({
    required this.cached,
    this.remotePosts = const [],
    this.remoteResult,
  }) : super(openDb: () => throw UnimplementedError());

  CachedPosts cached;
  final List<Post> remotePosts;
  final Completer<List<Post>>? remoteResult;
  int fetchRemoteCalls = 0;

  @override
  Future<CachedPosts> readCached() async => cached;

  @override
  Future<List<Post>> fetchRemote() {
    fetchRemoteCalls++;
    return remoteResult?.future ?? Future.value(remotePosts);
  }

  @override
  Future<void> saveCache(List<Post> posts) async {
    cached = CachedPosts(posts: posts, cachedAt: DateTime.now());
  }
}

void main() {
  test('postsProvider menampilkan cache tanpa menunggu remote', () async {
    final remoteResult = Completer<List<Post>>();
    final cachedPost = Post(
      userId: 1,
      id: 1,
      title: 'Cache',
      body: 'Tersimpan lokal',
    );
    final repository = FakePostRepository(
      cached: CachedPosts(posts: [cachedPost], cachedAt: DateTime(2026, 10, 1)),
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
    final repository = FakePostRepository(
      cached: CachedPosts(posts: [], cachedAt: null),
    );
    final container = ProviderContainer(
      retry: (count, error) => null,
      overrides: [postRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.read(forceOfflineProvider.notifier).toggle();

    await expectLater(
      container.read(postsProvider.future),
      throwsA(isA<OfflineException>()),
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
      cached: CachedPosts(posts: [cachedPost], cachedAt: DateTime(2026, 10, 1)),
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
}
