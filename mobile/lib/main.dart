import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/auth_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/websocket/ws_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: BancaDoPalpiteApp()));
}

class BancaDoPalpiteApp extends ConsumerWidget {
  const BancaDoPalpiteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Connect / disconnect WS based on auth state
    ref.listen(authProvider, (_, next) {
      final ws = ref.read(wsManagerProvider);
      final status = next.valueOrNull?.status;
      if (status == AuthStatus.authenticated) {
        ws.connect();
      } else {
        ws.disconnect();
      }
    });

    return MaterialApp.router(
      title: 'Banca do Palpite',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
