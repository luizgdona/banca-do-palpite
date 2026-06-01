import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/pool/screens/create_pool_screen.dart';
import '../../features/pool/screens/pool_detail_screen.dart';
import '../../features/pool/screens/join_pool_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoading = authAsync.isLoading;
      final isSplash = state.matchedLocation == '/splash';

      if (isLoading || isSplash) return null;

      final authState = authAsync.valueOrNull;
      final isAuth = authState?.status == AuthStatus.authenticated;

      final publicPaths = ['/login', '/register', '/onboarding'];
      final isPublicRoute = publicPaths.any(
        (p) => state.matchedLocation.startsWith(p),
      );
      // /join/:code is accessible but redirects to login if unauthenticated
      final isJoinRoute = state.matchedLocation.startsWith('/join/');

      if (!isAuth && !isPublicRoute && !isJoinRoute) return '/onboarding';
      if (isAuth && isPublicRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/pool/create', builder: (_, __) => const CreatePoolScreen()),
      GoRoute(
        path: '/pool/:id',
        builder: (_, state) => PoolDetailScreen(poolId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/join/:code',
        redirect: (context, state) {
          final auth = ref.read(authProvider).valueOrNull;
          if (auth?.status != AuthStatus.authenticated) {
            return '/login?redirect=${Uri.encodeComponent(state.uri.toString())}';
          }
          return null;
        },
        builder: (_, state) => JoinPoolScreen(
          inviteCode: state.pathParameters['code']!,
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Página não encontrada: ${state.error}')),
    ),
  );
});
