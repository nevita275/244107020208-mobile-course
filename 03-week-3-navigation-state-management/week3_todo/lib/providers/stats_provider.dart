import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider untuk sumber angka acak.
/// Dipisah agar pada unit test bisa diganti (override) dengan nilai tetap,
/// sehingga hasil "gagal 30%" bisa diuji secara deterministik.
final statsRandomProvider = Provider<Random>((ref) => Random());

/// Provider untuk lama delay simulasi jaringan.
/// Di aplikasi 2 detik, di test dibuat nol agar test cepat.
final statsDelayProvider =
    Provider<Duration>((ref) => const Duration(seconds: 2));

/// Notifier asinkron. Tipe state: `AsyncValue<List<String>>`
/// (loading / error / data otomatis dikelola Riverpod).
class StatsNotifier extends AsyncNotifier<List<String>> {
  /// build() dijalankan saat provider pertama kali dibaca.
  /// Selama Future belum selesai, state = AsyncLoading.
  @override
  Future<List<String>> build() => _fetch();

  /// Dipanggil tombol "Coba lagi".
  /// state diganti dengan objek baru (AsyncLoading, lalu hasil guard),
  /// tidak pernah dimutasi langsung.
  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  /// Simulasi pengambilan data: tunggu, lalu gagal dengan peluang 30%.
  Future<List<String>> _fetch() async {
    // ref dibaca SEBELUM await agar tidak dipakai setelah provider mungkin dibuang.
    final delay = ref.read(statsDelayProvider);
    final random = ref.read(statsRandomProvider);

    await Future.delayed(delay);

    if (random.nextDouble() < 0.3) {
      throw Exception('Gagal mengambil statistik');
    }
    return ['Pengguna aktif: 1.240', 'Sesi hari ini: 3.562', 'Rata-rata durasi: 4m 12d'];
  }
}

/// Provider dengan tipe eksplisit `<StatsNotifier, List<String>>`.
/// retry: (_, __) => null mematikan auto-retry bawaan Riverpod 3.x,
/// supaya error langsung tampil dan tombol "Coba lagi" bermakna.
final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<String>>(
  StatsNotifier.new,
  retry: (retryCount, error) => null,
);