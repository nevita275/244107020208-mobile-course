import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/notes_page.dart';
import 'pages/settings_page.dart';

void main() {
  // ProviderScope menyediakan container Riverpod untuk seluruh aplikasi.
  runApp(const ProviderScope(child: MyApp()));
}

// Root aplikasi memilih tema berdasarkan preferensi yang tersimpan.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);
    ref.watch(lastOpenedProvider);

    return MaterialApp(
      title: 'Pengaturan Catatan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: darkMode.when(
        data: (enabled) => enabled ? ThemeMode.dark : ThemeMode.light,
        loading: () => ThemeMode.light,
        error: (error, stackTrace) => ThemeMode.light,
      ),
      home: const NotesPage(),
    );
  }
}
