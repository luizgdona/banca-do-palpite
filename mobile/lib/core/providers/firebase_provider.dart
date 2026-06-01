import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notifications_provider.dart';

// Firebase Messaging é inicializado de forma lazy e apenas em plataformas nativas.
// Na web, FCM requer service worker adicional — deixado para configuração pós-Fase 5.
//
// Para ativar:
// 1. Copie google-services.json para android/app/ (Android)
// 2. Copie GoogleService-Info.plist para ios/Runner/ (iOS)
// 3. Descomente o bloco abaixo e adicione firebase_core + firebase_messaging ao pubspec

Future<void> initFirebaseMessaging(WidgetRef ref) async {
  // Apenas em plataformas nativas
  if (kIsWeb) return;

  try {
    // Lazy import — não quebra a build se os arquivos Firebase não estiverem presentes
    final core = await _tryImportFirebaseCore();
    if (core == null) return;

    final token = await _getFcmToken();
    if (token != null) {
      await registerFcmToken(ref, token);
    }

    _setupForegroundHandler();
  } catch (e) {
    // Firebase não configurado — notificações desativadas silenciosamente
    debugPrint('[FCM] não configurado: $e');
  }
}

// Estas funções são stubs — substituídas quando Firebase for configurado
Future<dynamic> _tryImportFirebaseCore() async {
  // Retorna null até que o google-services.json seja adicionado
  return null;
}

Future<String?> _getFcmToken() async {
  return null;
}

void _setupForegroundHandler() {
  // Configura handler de mensagens em foreground
  // FirebaseMessaging.onMessage.listen((message) { ... });
}
