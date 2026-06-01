import 'package:flutter_test/flutter_test.dart';
import 'package:banca_do_palpite/core/models/prediction_model.dart';

void main() {
  group('PredictionModel.fromJson', () {
    test('parseia palpite com pontos', () {
      final json = {
        'id': 'pred-1',
        'matchId': 'm-1',
        'homeScore': 2,
        'awayScore': 1,
        'pointsEarned': 3,
        'updatedAt': '2024-06-01T15:00:00.000Z',
      };

      final pred = PredictionModel.fromJson(json);

      expect(pred.id, 'pred-1');
      expect(pred.matchId, 'm-1');
      expect(pred.homeScore, 2);
      expect(pred.awayScore, 1);
      expect(pred.pointsEarned, 3);
      expect(pred.updatedAt, isNotNull);
    });

    test('pointsEarned default é 0', () {
      final json = {'matchId': 'm-1', 'homeScore': 0, 'awayScore': 0};
      final pred = PredictionModel.fromJson(json);
      expect(pred.pointsEarned, 0);
    });
  });

  group('predictionResultFromPoints', () {
    test('placar exato', () {
      expect(
        predictionResultFromPoints(3, 3, 1),
        PredictionResult.exact,
      );
    });

    test('resultado certo', () {
      expect(
        predictionResultFromPoints(1, 3, 1),
        PredictionResult.correct,
      );
    });

    test('zero pontos', () {
      expect(
        predictionResultFromPoints(0, 3, 1),
        PredictionResult.wrong,
      );
    });

    test('pending (sem pontos mas jogo não terminou)', () {
      expect(
        predictionResultFromPoints(0, 3, 1),
        PredictionResult.wrong,
      );
    });
  });

  group('MatchPredictionsResponse.fromJson', () {
    test('parseia resposta não revelada', () {
      final json = {
        'revealed': false,
        'predictedCount': 3,
        'totalMembers': 5,
        'myPrediction': null,
        'predictions': [],
      };

      final response = MatchPredictionsResponse.fromJson(json);

      expect(response.revealed, isFalse);
      expect(response.predictedCount, 3);
      expect(response.totalMembers, 5);
      expect(response.myPrediction, isNull);
      expect(response.predictions, isEmpty);
    });

    test('parseia resposta revelada com palpites', () {
      final json = {
        'revealed': true,
        'predictedCount': 2,
        'totalMembers': 3,
        'myPrediction': null,
        'predictions': [
          {
            'homeScore': 2,
            'awayScore': 1,
            'pointsEarned': 3,
            'user': {'id': 'u1', 'name': 'A', 'avatarUrl': null},
          },
        ],
      };

      final response = MatchPredictionsResponse.fromJson(json);

      expect(response.revealed, isTrue);
      expect(response.predictions, hasLength(1));
      expect(response.predictions.first.user.name, 'A');
      expect(response.predictions.first.pointsEarned, 3);
    });
  });
}
