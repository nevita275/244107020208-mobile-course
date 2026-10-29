import 'package:shared_preferences/shared_preferences.dart';

// Repository ini menjadi satu-satunya tempat akses preferensi lokal.
class PrefsRepository {
  static const _darkModeKey = 'dark_mode';
  static const _lastOpenedKey = 'last_opened_at';

  // Membaca tema tersimpan; nilai awal aplikasi adalah tema terang.
  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  // Menyimpan pilihan tema pengguna.
  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  // Mencatat waktu saat aplikasi dibuka.
  Future<void> markOpenedNow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastOpenedKey, DateTime.now().toIso8601String());
  }

  // Mengambil waktu pembukaan terakhir jika pernah disimpan.
  Future<String?> getLastOpened() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastOpenedKey);
  }
}
