import 'package:dio/dio.dart';

import '../models/comment.dart';

class CommentRepository {
  // Repository memakai instance Dio bersama yang diberikan melalui konstruktor.
  CommentRepository(this._dio);

  final Dio _dio;

  // Timeout mengikuti konfigurasi Dio dari client; ambil komentar lalu ubah JSON menjadi model.
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
    );
    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
