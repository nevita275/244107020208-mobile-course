import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/announcement_page.dart';
import 'pages/debug_fcm_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'messaging/push_service.dart';
import 'providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  registerBackgroundHandler();
  await initLocalNotifications();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  String? _pendingNotificationRoute;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || Firebase.apps.isEmpty) return;
      listenForeground(_openNotificationRoute);
      unawaited(_handleTerminatedNotification());
    });
  }

  Future<void> _handleTerminatedNotification() async {
    try {
      await handleTerminated(_openNotificationRoute);
    } catch (error) {
      recordPushError(error);
    }
  }

  void _openNotificationRoute(String requestedRoute) {
    final route = validatedNotificationRoute(requestedRoute);
    final authState = ref.read(authStateProvider);
    if (authState.isLoading || authState.value != true) {
      _pendingNotificationRoute = route;
      return;
    }
    _navigateToNotificationRoute(route);
  }

  void _navigateToNotificationRoute(String route) {
    final router = ref.read(routerProvider);
    if (route == '/') {
      router.go('/');
      return;
    }

    router.go('/');
    unawaited(router.push<void>(route));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (previous, next) {
      final pendingRoute = _pendingNotificationRoute;
      if (next.value == true && pendingRoute != null) {
        _pendingNotificationRoute = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _navigateToNotificationRoute(pendingRoute);
        });
      }
    });

    return MaterialApp.router(
      title: 'Campus Notify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();

  // Router tidak membaca container global: perubahan status auth memicu evaluasi redirect ulang.
  ref.listen(authStateProvider, (previous, next) => refreshNotifier.refresh());

  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final loggedIn = ref.read(authStateProvider).value ?? false;
      final goingLogin = state.matchedLocation == '/login';

      if (!loggedIn && !goingLogin) return '/login';
      if (loggedIn && goingLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/debug-fcm',
        builder: (context, state) => const DebugFcmPage(),
      ),
      GoRoute(
        path: '/pengumuman/:id',
        builder: (context, state) =>
            AnnouncementPage(id: state.pathParameters['id'] ?? ''),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refreshNotifier.dispose();
  });

  return router;
});

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}
