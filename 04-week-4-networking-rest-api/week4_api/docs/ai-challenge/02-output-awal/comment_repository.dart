import 'package:dio/dio.dart';

import '../models/comment.dart';

class CommentRepository {
  // Batas waktu permintaan disatukan dalam satu konstanta selama sepuluh detik.
  static const Duration requestTimeout = Duration(seconds: 10);

  // Repository memakai instance Dio bersama yang diberikan melalui konstruktor.
  CommentRepository(this._dio);

  final Dio _dio;

  // Mengambil komentar untuk satu post dan mengubah setiap objek JSON menjadi model.
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
      options: Options(
        connectTimeout: requestTimeout,
        sendTimeout: requestTimeout,
        receiveTimeout: requestTimeout,
      ),
    );
    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
