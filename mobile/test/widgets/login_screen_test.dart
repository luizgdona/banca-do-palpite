import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:banca_do_palpite/core/providers/auth_provider.dart';
import 'package:banca_do_palpite/core/theme/app_theme.dart';
import 'package:banca_do_palpite/features/auth/screens/login_screen.dart';

// Fake AuthNotifier que nunca tenta conectar à rede
class _FakeAuth extends AuthNotifier {
  @override
  Future<AuthState> build() async => const AuthState.unauthenticated();

  @override
  Future<void> login({required String email, required String password}) async {}
  @override
  Future<void> register({required String name, required String email, required String password}) async {}
  @override
  Future<void> logout() async {}
}

Widget buildLoginScreen() {
  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('Home'))),
      GoRoute(path: '/register', builder: (_, __) => const Scaffold(body: Text('Register'))),
    ],
  );

  return ProviderScope(
    overrides: [
      authProvider.overrideWith(_FakeAuth.new),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

void main() {
  group('LoginScreen', () {
    testWidgets('renderiza campos email e senha', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pump();

      expect(find.text('Email'), findsWidgets);
      expect(find.text('Senha'), findsWidgets);
      expect(find.text('ENTRAR'), findsWidgets);
    });

    testWidgets('mostra erro para email inválido', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'nao-e-email',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'ENTRAR'));
      await tester.pump();

      expect(find.text('Email inválido'), findsOneWidget);
    });

    testWidgets('mostra erro para senha vazia', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'valid@test.com',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'ENTRAR'));
      await tester.pump();

      expect(find.text('Informe sua senha'), findsOneWidget);
    });

    testWidgets('toggle de senha altera visibilidade', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pump();

      // Campo senha começa oculto
      final senhaField = find.widgetWithText(TextField, 'Senha');
      expect(tester.widget<TextField>(senhaField).obscureText, isTrue);

      // Toca no ícone de visibilidade
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      expect(tester.widget<TextField>(senhaField).obscureText, isFalse);
    });

    testWidgets('link para cadastro está visível', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pump();

      expect(find.text('Criar conta'), findsOneWidget);
    });
  });
}
