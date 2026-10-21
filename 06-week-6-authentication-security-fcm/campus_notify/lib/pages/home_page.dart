import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _pushInitializationStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_pushInitializationStarted) {
        _pushInitializationStarted = true;
        _initializePush();
      }
    });
  }

  Future<void> _initializePush() async {
    try {
      final dio = ref.read(dioProvider);
      await requestNotificationPermission();
      await initFcmToken(
        onToken: (token) => recordTokenSentToBackend(token, dio: dio),
      );
    } catch (error) {
      recordPushError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: ListView(
        children: [
          ListTile(
            title: const Text('Pengumuman'),
            subtitle: const Text('Buka pengumuman kampus'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/pengumuman/1'),
          ),
          ListTile(
            title: const Text('Debug FCM'),
            subtitle: const Text('Status izin dan token notifikasi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/debug-fcm'),
          ),
        ],
      ),
    );
  }
}
