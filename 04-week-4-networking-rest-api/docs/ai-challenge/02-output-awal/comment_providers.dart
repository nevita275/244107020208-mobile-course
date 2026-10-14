import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/comment.dart';
import 'providers.dart';
import 'repositories/comment_repository.dart';

// Repository komentar menggunakan Dio bersama dari provider praktikum sebelumnya.
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

class CommentNotifier extends AsyncNotifier<List<Comment>> {
  // ID post diteruskan melalui konstruktor family Riverpod.
  CommentNotifier(this.postId);

  final int postId;

  // Future yang dikembalikan otomatis menjadi AsyncData atau AsyncError.
  @override
  Future<List<Comment>> build() {
    return ref.watch(commentRepositoryProvider).fetchComments(postId);
  }
}

// Retry otomatis dimatikan agar kegagalan langsung tampak sebagai AsyncError.
final commentProvider =
    AsyncNotifierProvider.family<CommentNotifier, List<Comment>, int>(
  CommentNotifier.new,
  retry: (retryCount, error) => null,
);

// Mengubah kegagalan jaringan menjadi pesan Bahasa Indonesia tanpa detail teknis mentah.
String commentErrorMessage(Object error) {
  if (error is! DioException) {
    return 'Terjadi kesalahan tak terduga. Coba lagi nanti.';
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return 'Koneksi terlalu lambat atau waktu permintaan habis. Periksa internet Anda lalu coba lagi.';
    case DioExceptionType.connectionError:
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      if (statusCode == 404) {
        return 'Komentar tidak ditemukan (404).';
      }
      if (statusCode == 500) {
        return 'Server sedang bermasalah (500). Coba lagi nanti.';
      }
      return 'Server mengembalikan respons yang bermasalah. Coba lagi nanti.';
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return 'Terjadi kesalahan jaringan. Coba lagi nanti.';
  }
}
