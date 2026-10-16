import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import 'local/db.dart';
import 'post.dart';

// Menandai kegagalan jaringan yang membuat sumber remote tidak tersedia.
class OfflineException implements Exception {
  const OfflineException([this.message = 'Tidak ada koneksi internet']);

  final String message;

  @override
  String toString() => message;
}

// Hasil pembacaan cache beserta waktu cache terbaru yang tersedia.
class CachedPosts {
  CachedPosts({required List<Post> posts, required this.cachedAt})
    : posts = List.unmodifiable(posts);

  final List<Post> posts;
  final DateTime? cachedAt;
}

// Repository mengatur Dio dan cache SQLite untuk data posts.
class PostRepository {
  PostRepository({Future<Database> Function()? openDb, Dio? dio})
    : _openDb = openDb ?? openNotesDb,
      _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://jsonplaceholder.typicode.com',
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
            ),
          );

  final Future<Database> Function() _openDb;
  final Dio _dio;

  // Mengambil daftar post remote dan mengubah kegagalan koneksi menjadi offline.
  Future<List<Post>> fetchRemote() async {
    try {
      final response = await _dio.get<List<dynamic>>('/posts');
      return (response.data ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(Post.fromJson)
          .toList();
    } on DioException catch (error) {
      if (_isOfflineFailure(error.type)) {
        throw OfflineException('Tidak dapat terhubung ke server.');
      }
      rethrow;
    }
  }

  // Membaca post dari cache dan memilih waktu cache yang paling baru.
  Future<CachedPosts> readCached() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    final posts = <Post>[];
    DateTime? newestCacheTime;

    for (final row in rows) {
      final payload = jsonDecode(row['payload'] as String);
      if (payload is Map<String, dynamic>) {
        posts.add(Post.fromJson(payload));
      }
      final cachedTime = DateTime.tryParse(row['cached_at'] as String? ?? '');
      if (cachedTime != null &&
          (newestCacheTime == null || cachedTime.isAfter(newestCacheTime))) {
        newestCacheTime = cachedTime;
      }
    }
    return CachedPosts(posts: posts, cachedAt: newestCacheTime);
  }

  // Mengganti isi cache dalam satu batch dengan payload JSON dan waktu seragam.
  Future<void> saveCache(List<Post> posts) async {
    final db = await _openDb();
    final cachedAt = DateTime.now().toIso8601String();
    final batch = db.batch();
    batch.delete('cached_posts');
    for (final post in posts) {
      batch.insert('cached_posts', {
        'id': post.id,
        'payload': jsonEncode(post.toJson()),
        'cached_at': cachedAt,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  bool _isOfflineFailure(DioExceptionType type) {
    return type == DioExceptionType.connectionError ||
        type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.sendTimeout;
  }
}
