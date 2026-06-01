import 'package:flutter_test/flutter_test.dart';
import 'package:banca_do_palpite/core/models/match_model.dart';

void main() {
  final futureDate = DateTime.now().add(const Duration(hours: 2));
  final pastDate = DateTime.now().subtract(const Duration(hours: 1));

  Map<String, dynamic> matchJson({
    String status = 'scheduled',
    DateTime? scheduledAt,
    int? homeScore,
    int? awayScore,
  }) =>
      {
        'id': 'm-1',
        'homeTeam': {'id': 1, 'name': 'Brasil', 'logo': 'https://example.com/br.png'},
        'awayTeam': {'id': 2, 'name': 'Argentina', 'logo': null},
        'scheduledAt': (scheduledAt ?? futureDate).toIso8601String(),
        'status': status,
        'homeScore': homeScore,
        'awayScore': awayScore,
      };

  group('MatchModel.fromJson', () {
    test('parseia todos os campos', () {
      final match = MatchModel.fromJson(matchJson(
        status: 'live',
        homeScore: 2,
        awayScore: 1,
      ));

      expect(match.id, 'm-1');
      expect(match.homeTeam.name, 'Brasil');
      expect(match.awayTeam.name, 'Argentina');
      expect(match.status, MatchStatus.live);
      expect(match.homeScore, 2);
      expect(match.awayScore, 1);
    });

    test('status desconhecido vira scheduled', () {
      final match = MatchModel.fromJson(matchJson(status: 'unknown_status'));
      expect(match.status, MatchStatus.scheduled);
    });

    test('campos opcionais são nulos', () {
      final match = MatchModel.fromJson(matchJson());
      expect(match.homeScore, isNull);
      expect(match.minute, isNull);
    });
  });

  group('MatchModel.isLocked', () {
    test('false para jogo no futuro com status scheduled', () {
      final match = MatchModel.fromJson(matchJson(scheduledAt: futureDate));
      expect(match.isLocked, isFalse);
    });

    test('true para jogo no passado', () {
      final match = MatchModel.fromJson(matchJson(scheduledAt: pastDate));
      expect(match.isLocked, isTrue);
    });

    test('true para status live', () {
      final match = MatchModel.fromJson(matchJson(status: 'live', scheduledAt: futureDate));
      expect(match.isLocked, isTrue);
    });

    test('true para status finished', () {
      final match = MatchModel.fromJson(matchJson(status: 'finished'));
      expect(match.isLocked, isTrue);
    });
  });

  group('TeamInfo.fromJson', () {
    test('parseia logo nula', () {
      final team = TeamInfo.fromJson({'name': 'Time X', 'logo': null});
      expect(team.logo, isNull);
    });

    test('id pode ser nulo', () {
      final team = TeamInfo.fromJson({'name': 'Time X'});
      expect(team.id, isNull);
    });
  });

  group('matchStatusFromString', () {
    test('mapeia todos os valores válidos', () {
      expect(matchStatusFromString('scheduled'), MatchStatus.scheduled);
      expect(matchStatusFromString('live'), MatchStatus.live);
      expect(matchStatusFromString('finished'), MatchStatus.finished);
      expect(matchStatusFromString('postponed'), MatchStatus.postponed);
      expect(matchStatusFromString('cancelled'), MatchStatus.cancelled);
    });

    test('valor desconhecido retorna scheduled', () {
      expect(matchStatusFromString('xyz'), MatchStatus.scheduled);
    });
  });
}
