import 'package:flutter_test/flutter_test.dart';
import 'package:banca_do_palpite/core/models/ranking_model.dart';

void main() {
  group('RankingEntry.fromJson', () {
    test('parseia entrada de ranking completa', () {
      final json = {
        'position': 1,
        'user': {'id': 'u1', 'name': 'Rafael', 'avatarUrl': null},
        'totalPoints': 21,
        'exactCount': 3,
        'isMe': true,
      };

      final entry = RankingEntry.fromJson(json);

      expect(entry.position, 1);
      expect(entry.user.name, 'Rafael');
      expect(entry.totalPoints, 21);
      expect(entry.exactCount, 3);
      expect(entry.isMe, isTrue);
    });

    test('exactCount default é 0', () {
      final json = {
        'position': 2,
        'user': {'id': 'u2', 'name': 'B', 'avatarUrl': null},
        'totalPoints': 10,
        'isMe': false,
      };

      final entry = RankingEntry.fromJson(json);
      expect(entry.exactCount, 0);
    });

    test('isMe default é false', () {
      final json = {
        'position': 3,
        'user': {'id': 'u3', 'name': 'C', 'avatarUrl': null},
        'totalPoints': 5,
        'exactCount': 1,
      };

      final entry = RankingEntry.fromJson(json);
      expect(entry.isMe, isFalse);
    });
  });
}
