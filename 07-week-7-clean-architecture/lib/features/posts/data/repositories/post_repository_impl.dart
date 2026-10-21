import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/failures.dart';
import '../../../../data/local/db.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../models/post_model.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({Future<Database> Function()? openDb, Dio? dio})
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

  @override
  Future<({List<Post> posts, Failure? failure})> fetchRemote() async {
    try {
      final response = await _dio.get<List<dynamic>>('/posts');
      final posts = (response.data ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((json) => PostModel.fromJson(json).toEntity())
          .toList();
      return (posts: posts, failure: null);
    } on DioException {
      return (
        posts: const <Post>[],
        failure: const NetworkFailure('Data posts tidak dapat dimuat.'),
      );
    } on Exception {
      return (
        posts: const <Post>[],
        failure: const NetworkFailure('Respons server tidak dapat diproses.'),
      );
    }
  }

  @override
  Future<({List<Post> posts, DateTime? cachedAt, Failure? failure})>
  readCached() async {
    try {
      final db = await _openDb();
      final rows = await db.query('cached_posts', orderBy: 'id ASC');
      final posts = <Post>[];
      DateTime? newestCacheTime;

      for (final row in rows) {
        final payload = jsonDecode(row['payload'] as String);
        if (payload is Map<String, dynamic>) {
          posts.add(PostModel.fromJson(payload).toEntity());
        }
        final cachedTime = DateTime.tryParse(row['cached_at'] as String? ?? '');
        if (cachedTime != null &&
            (newestCacheTime == null || cachedTime.isAfter(newestCacheTime))) {
          newestCacheTime = cachedTime;
        }
      }
      return (posts: posts, cachedAt: newestCacheTime, failure: null);
    } on Exception {
      return (
        posts: const <Post>[],
        cachedAt: null,
        failure: const LocalFailure('Cache posts tidak dapat dibaca.'),
      );
    }
  }

  @override
  Future<Failure?> saveCache(List<Post> posts) async {
    try {
      final db = await _openDb();
      final cachedAt = DateTime.now().toIso8601String();
      final batch = db.batch();
      batch.delete('cached_posts');
      for (final post in posts) {
        batch.insert('cached_posts', {
          'id': post.id,
          'payload': jsonEncode(
            PostModel(
              userId: post.userId,
              id: post.id,
              title: post.title,
              body: post.body,
            ).toJson(),
          ),
          'cached_at': cachedAt,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
      return null;
    } on Exception {
      return const LocalFailure('Cache posts tidak dapat disimpan.');
    }
  }
}
