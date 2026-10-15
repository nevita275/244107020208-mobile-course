import 'package:dio/dio.dart';

// Satu batas waktu bersama agar konfigurasi timeout tidak tersebar di repository.
const Duration apiTimeout = Duration(seconds: 10);

Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: apiTimeout,
      sendTimeout: apiTimeout,
      receiveTimeout: apiTimeout,
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(
    LogInterceptor(requestBody: true, responseBody: false),
  );
  return dio;
}
