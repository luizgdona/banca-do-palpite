import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../network/api_client.dart';
import '../providers/auth_provider.dart' show apiClientProvider;
import 'ws_message.dart';

const _wsBaseUrl = String.fromEnvironment(
  'WS_URL',
  defaultValue: 'ws://10.0.2.2:3000/ws',
);

enum WsStatus { disconnected, connecting, connected, error }

class WsManager {
  final ApiClient _apiClient;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  int _retryCount = 0;
  static const int _maxRetries = 10;

  final _messageController = StreamController<WsMessage>.broadcast();
  final _statusNotifier = ValueNotifier(WsStatus.disconnected);

  Stream<WsMessage> get messages => _messageController.stream;
  ValueListenable<WsStatus> get statusListenable => _statusNotifier;
  WsStatus get status => _statusNotifier.value;

  WsManager(this._apiClient);

  Future<void> connect() async {
    if (_statusNotifier.value == WsStatus.connecting ||
        _statusNotifier.value == WsStatus.connected) return;

    _statusNotifier.value = WsStatus.connecting;

    final token = await _apiClient.getAccessToken();
    if (token == null) {
      _statusNotifier.value = WsStatus.disconnected;
      return;
    }

    try {
      final uri = Uri.parse('$_wsBaseUrl?token=${Uri.encodeComponent(token)}');
      _channel = WebSocketChannel.connect(uri);

      await _channel!.ready;

      _statusNotifier.value = WsStatus.connected;
      _retryCount = 0;

      _sub = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      // Client-side ping every 25s to complement server-side 30s heartbeat
      _pingTimer?.cancel();
      _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
        _send({'type': 'ping'});
      });
    } catch (e) {
      _statusNotifier.value = WsStatus.error;
      _scheduleReconnect();
    }
  }

  void subscribe(List<String> poolIds) {
    if (poolIds.isEmpty) return;
    _send({'type': 'subscribe', 'poolIds': poolIds});
  }

  void unsubscribe(List<String> poolIds) {
    if (poolIds.isEmpty) return;
    _send({'type': 'unsubscribe', 'poolIds': poolIds});
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _sub?.cancel();
    _channel?.sink.close();
    _channel = null;
    _statusNotifier.value = WsStatus.disconnected;
    _retryCount = 0;
  }

  void _onMessage(dynamic raw) {
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;
      final msg = WsMessage.fromJson(json);
      _messageController.add(msg);
    } catch (_) {}
  }

  void _onError(Object err) {
    _statusNotifier.value = WsStatus.error;
    _scheduleReconnect();
  }

  void _onDone() {
    if (_statusNotifier.value == WsStatus.connected) {
      _statusNotifier.value = WsStatus.disconnected;
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_retryCount >= _maxRetries) return;
    _retryCount++;
    // Exponential backoff: 2s, 4s, 8s … capped at 60s
    final delay = Duration(seconds: (2 << (_retryCount - 1)).clamp(2, 60));
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, connect);
  }

  void _send(Map<String, dynamic> data) {
    try {
      if (_channel != null && _statusNotifier.value == WsStatus.connected) {
        _channel!.sink.add(jsonEncode(data));
      }
    } catch (_) {}
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _statusNotifier.dispose();
  }
}

// ── Providers ────────────────────────────────────────────────────────────────

final wsManagerProvider = Provider<WsManager>((ref) {
  final client = ref.read(apiClientProvider);
  final manager = WsManager(client);
  ref.onDispose(manager.dispose);
  return manager;
});

// Conecta automaticamente quando o provider é lido pela primeira vez
final wsConnectionProvider = Provider<WsManager>((ref) {
  final manager = ref.watch(wsManagerProvider);
  manager.connect();
  return manager;
});

// Stream de mensagens como AsyncValue para widgets consumirem com watch
final wsMessagesProvider = StreamProvider<WsMessage>((ref) {
  final manager = ref.watch(wsManagerProvider);
  return manager.messages;
});
