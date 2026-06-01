import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:banca_do_palpite/core/websocket/ws_message.dart';

// Unit tests for pure logic extracted from WsManager
// (não testamos a conexão real pois requer servidor WebSocket)

void main() {
  group('WsMessage sealed class', () {
    test('todos os subtipos são distintos', () {
      final types = [
        WsMessage.fromJson({'type': 'pong'}),
        WsMessage.fromJson({'type': 'pool:ranking_updated', 'poolId': 'p'}),
        WsMessage.fromJson({
          'type': 'match:score_update',
          'matchId': 'm', 'homeScore': 0, 'awayScore': 0,
          'minute': null, 'status': 'live',
        }),
        WsMessage.fromJson({
          'type': 'match:finished',
          'matchId': 'm', 'homeScore': 1, 'awayScore': 0,
        }),
        WsMessage.fromJson({
          'type': 'prediction:revealed',
          'poolId': 'p', 'matchId': 'm',
        }),
      ];

      final typeNames = types.map((t) => t.runtimeType.toString()).toSet();
      expect(typeNames.length, types.length);
    });
  });

  group('WsManager reconnect logic', () {
    test('delay cresce exponencialmente', () {
      // Simula o cálculo de backoff: 2 << (retry - 1), capped at 60
      int backoff(int retry) => (2 << (retry - 1)).clamp(2, 60);

      expect(backoff(1), 2);   // 2 << 0 = 2
      expect(backoff(2), 4);   // 2 << 1
      expect(backoff(3), 8);   // 2 << 2
      expect(backoff(4), 16);  // 2 << 3
      expect(backoff(5), 32);  // 2 << 4
      expect(backoff(6), 60);  // capped (64 > 60)
      expect(backoff(10), 60); // sempre capped
    });

    test('delay nunca passa de 60', () {
      for (int i = 1; i <= 20; i++) {
        final delay = (2 << (i - 1)).clamp(2, 60);
        expect(delay, lessThanOrEqualTo(60));
      }
    });
  });

  group('invite code validation', () {
    // Lógica do DeepLinksHandler
    bool isValidCode(String code) => RegExp(r'^[A-Z0-9]{8}$').hasMatch(code);

    test('código válido', () {
      expect(isValidCode('ABCD1234'), isTrue);
      expect(isValidCode('ZZZZZZZZ'), isTrue);
      expect(isValidCode('00000000'), isTrue);
    });

    test('código inválido — minúsculas', () {
      expect(isValidCode('abcd1234'), isFalse);
    });

    test('código inválido — comprimento errado', () {
      expect(isValidCode('ABC123'), isFalse);
      expect(isValidCode('ABCD12345'), isFalse);
    });

    test('código inválido — caracteres especiais', () {
      expect(isValidCode('ABC-1234'), isFalse);
      expect(isValidCode('ABC 1234'), isFalse);
    });
  });
}
