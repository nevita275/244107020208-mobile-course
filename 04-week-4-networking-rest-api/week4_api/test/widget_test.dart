import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/post_repository.dart';
import 'package:week4_api/main.dart';

// Repository palsu dipakai agar tes tidak mengirim HTTP, yang diblokir test harness Flutter.
class FakePostRepository implements PostRepository {
  FakePostRepository({this.posts = const [], this.error});

  final List<Post> posts;
  final Object? error;

  @override
  Future<List<Post>> fetchPosts() async => posts;

  @override
  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) async {
    if (error != null) throw error!;
    return page == 1 ? posts : const [];
  }
}

void main() {
  testWidgets('Menampilkan judul dan post dari repository palsu', (
    WidgetTester tester,
  ) async {
    const posts = [
      Post(userId: 1, id: 1, title: 'Judul post palsu', body: 'Isi post palsu'),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWithValue(
            FakePostRepository(posts: posts),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Posts Paged'), findsOneWidget);
    expect(find.text('Judul post palsu'), findsOneWidget);
  });

  testWidgets('Menampilkan pesan koneksi dan tombol coba lagi saat error', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWithValue(
            FakePostRepository(
              error: DioException(
                requestOptions: RequestOptions(path: '/posts'),
                type: DioExceptionType.connectionError,
              ),
            ),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Tidak dapat terhubung ke server. Periksa internet Anda.'),
      findsOneWidget,
    );
    expect(find.text('Coba lagi'), findsOneWidget);
  });
}
