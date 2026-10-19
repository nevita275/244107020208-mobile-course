import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  // Seluruh token hanya keluar-masuk lewat kelas ini; token tidak disimpan di SharedPreferences karena tidak terenkripsi.
  Future<void> save({required String access, required String refresh}) async {
    await _storage.write(key: accessTokenKey, value: access);
    await _storage.write(key: refreshTokenKey, value: refresh);
  }

  Future<String?> readAccess() {
    return _storage.read(key: accessTokenKey);
  }

  Future<String?> readRefresh() {
    return _storage.read(key: refreshTokenKey);
  }

  Future<void> clear() {
    return _storage.deleteAll();
  }
}
