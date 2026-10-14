// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:week4_api/main.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/models/post.dart';

void main() {
  testWidgets('Menampilkan halaman Posts API yang kosong', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postListProvider.overrideWith(() => _EmptyPostListNotifier()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Posts API'), findsOneWidget);
    expect(find.text('Belum ada data dari server.'), findsOneWidget);
  });
}

class _EmptyPostListNotifier extends PostListNotifier {
  @override
  Future<List<Post>> build() async => const [];
}
