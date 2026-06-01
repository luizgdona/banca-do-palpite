import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:banca_do_palpite/core/providers/auth_provider.dart';
import 'package:banca_do_palpite/core/providers/pools_provider.dart';
import 'package:banca_do_palpite/core/models/user_model.dart';
import 'package:banca_do_palpite/core/models/pool_model.dart';
import 'package:banca_do_palpite/core/theme/app_theme.dart';
import 'package:banca_do_palpite/features/home/screens/home_screen.dart';

Widget buildHomeScreen({
  UserModel? user,
  List<PoolModel> pools = const [],
}) {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const Scaffold(body: Text('Profile'))),
      GoRoute(path: '/pool/create', builder: (_, __) => const Scaffold(body: Text('Create'))),
      GoRoute(path: '/join/:code', builder: (_, state) => Scaffold(body: Text('Join ${state.pathParameters["code"]}'))),
    ],
  );

  return ProviderScope(
    overrides: [
      authProvider.overrideWith(() => _FakeAuthNotifier(user)),
      poolsProvider.overrideWith(() => _FakePoolsNotifier(pools)),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

// Fake AuthNotifier — subclasse de AuthNotifier para compatibilidade com overrideWith
class _FakeAuthNotifier extends AuthNotifier {
  final UserModel? _user;
  _FakeAuthNotifier(this._user);

  @override
  Future<AuthState> build() async {
    if (_user != null) return AuthState.authenticated(_user!);
    return const AuthState.unauthenticated();
  }

  @override
  Future<void> login({required String email, required String password}) async {}
  @override
  Future<void> register({required String name, required String email, required String password}) async {}
  @override
  Future<void> logout() async {}
}

// Fake PoolsNotifier — subclasse de PoolsNotifier para compatibilidade com overrideWith
class _FakePoolsNotifier extends PoolsNotifier {
  final List<PoolModel> _pools;
  _FakePoolsNotifier(this._pools);

  @override
  Future<List<PoolModel>> build() async => _pools;

  @override
  Future<void> refresh() async {}

  @override
  Future<PoolModel> create({
    required String name,
    String? description,
    required String competitionId,
    required List<String> matchIds,
    int scoringExact = 3,
    int scoringResult = 1,
    bool isPublic = false,
  }) => throw UnimplementedError();
}

void main() {
  const testUser = UserModel(id: 'u1', name: 'Rafael Doná', email: 'r@t.com');

  group('HomeScreen', () {
    testWidgets('exibe saudação com primeiro nome', (tester) async {
      await tester.pumpWidget(buildHomeScreen(user: testUser));
      await tester.pumpAndSettle();

      expect(find.textContaining('Rafael'), findsWidgets);
    });

    testWidgets('exibe estado vazio quando não há bolões', (tester) async {
      await tester.pumpWidget(buildHomeScreen(user: testUser, pools: []));
      await tester.pumpAndSettle();

      expect(find.text('Nenhum bolão ainda'), findsOneWidget);
    });

    testWidgets('botão CRIAR BOLÃO está presente', (tester) async {
      await tester.pumpWidget(buildHomeScreen(user: testUser));
      await tester.pumpAndSettle();

      expect(find.text('CRIAR BOLÃO'), findsOneWidget);
    });

    testWidgets('botão ENTRAR está presente', (tester) async {
      await tester.pumpWidget(buildHomeScreen(user: testUser));
      await tester.pumpAndSettle();

      expect(find.text('ENTRAR'), findsOneWidget);
    });

    testWidgets('diálogo de código abre ao tocar em ENTRAR', (tester) async {
      await tester.pumpWidget(buildHomeScreen(user: testUser));
      await tester.pumpAndSettle();

      await tester.tap(find.text('ENTRAR'));
      await tester.pumpAndSettle();

      expect(find.text('ENTRAR COM CÓDIGO'), findsOneWidget);
    });
  });
}
