import 'package:dio/dio.dart';

// Dipakai bersama oleh halaman paged dan non-paged.
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
