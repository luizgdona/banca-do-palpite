import 'package:flutter_test/flutter_test.dart';
import 'package:banca_do_palpite/core/websocket/ws_message.dart';

void main() {
  group('WsMessage.fromJson', () {
    test('parseia match:score_update', () {
      final msg = WsMessage.fromJson({
        'type': 'match:score_update',
        'matchId': 'm-1',
        'homeScore': 2,
        'awayScore': 0,
        'minute': 45,
        'status': 'live',
      });

      expect(msg, isA<WsScoreUpdate>());
      final update = msg as WsScoreUpdate;
      expect(update.matchId, 'm-1');
      expect(update.homeScore, 2);
      expect(update.awayScore, 0);
      expect(update.minute, 45);
      expect(update.status, 'live');
    });

    test('parseia match:score_update sem minute', () {
      final msg = WsMessage.fromJson({
        'type': 'match:score_update',
        'matchId': 'm-1',
        'homeScore': 1,
        'awayScore': 1,
        'minute': null,
        'status': 'live',
      });

      final update = msg as WsScoreUpdate;
      expect(update.minute, isNull);
    });

    test('parseia match:finished', () {
      final msg = WsMessage.fromJson({
        'type': 'match:finished',
        'matchId': 'm-2',
        'homeScore': 3,
        'awayScore': 1,
      });

      expect(msg, isA<WsMatchFinished>());
      final finished = msg as WsMatchFinished;
      expect(finished.matchId, 'm-2');
      expect(finished.homeScore, 3);
    });

    test('parseia pool:ranking_updated', () {
      final msg = WsMessage.fromJson({
        'type': 'pool:ranking_updated',
        'poolId': 'p-1',
      });

      expect(msg, isA<WsRankingUpdated>());
      expect((msg as WsRankingUpdated).poolId, 'p-1');
    });

    test('parseia prediction:revealed', () {
      final msg = WsMessage.fromJson({
        'type': 'prediction:revealed',
        'poolId': 'p-1',
        'matchId': 'm-1',
      });

      expect(msg, isA<WsPredictionRevealed>());
      final revealed = msg as WsPredictionRevealed;
      expect(revealed.poolId, 'p-1');
      expect(revealed.matchId, 'm-1');
    });

    test('parseia pong', () {
      final msg = WsMessage.fromJson({'type': 'pong'});
      expect(msg, isA<WsPong>());
    });

    test('tipo desconhecido vira WsUnknown', () {
      final msg = WsMessage.fromJson({'type': 'unknown_type', 'data': 'xyz'});
      expect(msg, isA<WsUnknown>());
    });
  });
}
