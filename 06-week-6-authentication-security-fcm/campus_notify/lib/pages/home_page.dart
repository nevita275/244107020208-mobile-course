import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        actions: [
          TextButton(
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
            child: const Text('Keluar'),
          ),
        ],
      ),
      body: ListTile(
        title: const Text('Pengumuman'),
        subtitle: const Text('Buka pengumuman kampus'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/pengumuman/1'),
      ),
    );
  }
}
