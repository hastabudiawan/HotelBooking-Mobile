import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/account_page.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/home/api_check_page.dart';
import '../../features/splash/splash_page.dart';
import '../widgets/app_shell.dart';
import '../widgets/placeholder_page.dart';
import 'app_redirect.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Memberi tahu router untuk mengecek ulang pengalihan saat status login berubah.
  final authChanges = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (previous, next) => authChanges.value++);
  ref.onDispose(authChanges.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authChanges,
    redirect: (context, state) => authRedirect(
      loggedIn: ref.read(authControllerProvider) != null,
      uri: state.uri,
    ),
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            LoginPage(next: state.uri.queryParameters['next']),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) =>
            RegisterPage(next: state.uri.queryParameters['next']),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const ApiCheckPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                builder: (context, state) =>
                    const PlaceholderPage(title: 'Booking'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rooms',
                builder: (context, state) =>
                    const PlaceholderPage(title: 'Rooms'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                builder: (context, state) => const AccountPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
