import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'auth_repository.dart';
import 'token_store.dart';

Dio buildApiClient(TokenStore store, AuthRepository auth) {
  late final Dio dio;
  dio = Dio(BaseOptions(baseUrl: 'https://example-campus-api.test'))
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final access = await store.readAccess();
          if (access != null) {
            options.headers['Authorization'] = 'Bearer $access';
          }
          if (kDebugMode &&
              options.method == 'POST' &&
              options.path == '/devices') {
            // Simulasi backend /devices untuk pengembangan/debug saja.
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {'status': 'ok'},
              ),
            );
            return;
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final options = error.requestOptions;
          if (error.response?.statusCode != 401 ||
              options.extra['retried'] == true) {
            handler.next(error);
            return;
          }

          final refresh = await store.readRefresh();
          if (refresh == null) {
            handler.next(error);
            return;
          }

          late final String renewed;
          try {
            renewed = await auth.refresh(refresh);
            await store.save(access: renewed, refresh: refresh);
          } catch (_) {
            await store.clear();
            handler.next(error);
            return;
          }

          // Penanda ini membatasi refresh ke satu kali agar 401 pada retry tidak membuat loop.
          options.extra['retried'] = true;
          options.headers['Authorization'] = 'Bearer $renewed';
          try {
            final retryResponse = await dio.fetch<dynamic>(options);
            handler.resolve(retryResponse);
          } on DioException catch (retryError) {
            handler.next(retryError);
          }
        },
      ),
    );
  return dio;
}
