import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/prefs.dart';
import '../data/providers.dart';

// Provider repository agar dependensi penyimpanan mudah diganti saat diuji.
final prefsRepositoryProvider = Provider<PrefsRepository>(
  (ref) => PrefsRepository(),
);

final lastOpenedProvider = FutureProvider<String?>((ref) async {
  final repository = ref.watch(prefsRepositoryProvider);
  final previousOpened = await repository.getLastOpened();
  await repository.markOpenedNow();
  return previousOpened;
});

// Provider async mengelola status loading, error, dan nilai tema.
final darkModeProvider = AsyncNotifierProvider<DarkModeNotifier, bool>(
  DarkModeNotifier.new,
);

class DarkModeNotifier extends AsyncNotifier<bool> {
  // Nilai awal dibaca dari preferensi lokal.
  @override
  Future<bool> build() async {
    final repository = ref.watch(prefsRepositoryProvider);
    return repository.getDarkMode();
  }

  // Mengubah state dan menyimpan pilihan baru, sambil menangkap error.
  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

// Halaman pengaturan merender setiap kemungkinan state provider.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);
    final forceOffline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: Column(
        children: [
          Expanded(
            child: darkMode.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Preferensi tidak dapat dimuat.'),
                    TextButton(
                      onPressed: () => ref.invalidate(darkModeProvider),
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
              data: (enabled) => SwitchListTile(
                title: const Text('Mode gelap'),
                value: enabled,
                onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Simulasi offline'),
            value: forceOffline,
            onChanged: (_) => ref.read(forceOfflineProvider.notifier).toggle(),
          ),
          Consumer(
            builder: (context, ref, _) {
              final lastOpened = ref.watch(lastOpenedProvider);
              return lastOpened.when(
                loading: () => const ListTile(
                  title: Text('Terakhir dibuka'),
                  subtitle: Text('Memuat waktu pembukaan sebelumnya...'),
                ),
                error: (error, stackTrace) => const ListTile(
                  title: Text('Terakhir dibuka'),
                  subtitle: Text('Waktu pembukaan sebelumnya tidak tersedia'),
                ),
                data: (value) => ListTile(
                  title: const Text('Terakhir dibuka'),
                  subtitle: Text(
                    value == null
                        ? 'Belum pernah dibuka'
                        : DateTime.tryParse(value)?.toLocal().toString() ??
                              value,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
