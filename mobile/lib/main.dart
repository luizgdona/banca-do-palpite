import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/deep_links_provider.dart';
import 'core/providers/firebase_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/websocket/ws_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: BancaDoPalpiteApp()));
}

class BancaDoPalpiteApp extends ConsumerStatefulWidget {
  const BancaDoPalpiteApp({super.key});

  @override
  ConsumerState<BancaDoPalpiteApp> createState() => _BancaDoPalpiteAppState();
}

class _BancaDoPalpiteAppState extends ConsumerState<BancaDoPalpiteApp> {
  @override
  void initState() {
    super.initState();
    // Initialize deep links after first frame (router must be ready)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(routerProvider);
      ref.read(deepLinksHandlerProvider).init(router);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    // Connect / disconnect WS based on auth state
    ref.listen(authProvider, (_, next) {
      final ws = ref.read(wsManagerProvider);
      final status = next.valueOrNull?.status;
      if (status == AuthStatus.authenticated) {
        ws.connect();
        // Init Firebase Messaging after login
        initFirebaseMessaging(ref);
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
