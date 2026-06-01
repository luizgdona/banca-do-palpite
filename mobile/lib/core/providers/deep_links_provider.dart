import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Escuta deep links e redireciona para a rota correta
class DeepLinksHandler {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  void init(GoRouter router) {
    // Link que abriu o app a partir do estado fechado
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleUri(router, uri);
    }).catchError((e) {
      debugPrint('[DeepLinks] getInitialLink error: $e');
    });

    // Links recebidos com o app em foreground/background
    _sub = _appLinks.uriLinkStream.listen(
      (uri) => _handleUri(router, uri),
      onError: (e) => debugPrint('[DeepLinks] stream error: $e'),
    );
  }

  void dispose() {
    _sub?.cancel();
  }

  void _handleUri(GoRouter router, Uri uri) {
    debugPrint('[DeepLinks] received: $uri');
    // bancadopalpite.app/join/ABCD1234
    if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'join') {
      final code = uri.pathSegments[1].toUpperCase();
      if (RegExp(r'^[A-Z0-9]{8}$').hasMatch(code)) {
        router.push('/join/$code');
      }
    }
  }
}

final deepLinksHandlerProvider = Provider<DeepLinksHandler>((ref) {
  final handler = DeepLinksHandler();
  ref.onDispose(handler.dispose);
  return handler;
});
