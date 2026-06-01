// Mensagens recebidas do servidor
sealed class WsMessage {
  const WsMessage();

  factory WsMessage.fromJson(Map<String, dynamic> json) {
    return switch (json['type'] as String) {
      'match:score_update' => WsScoreUpdate(
          matchId: json['matchId'] as String,
          homeScore: json['homeScore'] as int,
          awayScore: json['awayScore'] as int,
          minute: json['minute'] as int?,
          status: json['status'] as String,
        ),
      'match:finished' => WsMatchFinished(
          matchId: json['matchId'] as String,
          homeScore: json['homeScore'] as int,
          awayScore: json['awayScore'] as int,
        ),
      'pool:ranking_updated' => WsRankingUpdated(
          poolId: json['poolId'] as String,
        ),
      'prediction:revealed' => WsPredictionRevealed(
          poolId: json['poolId'] as String,
          matchId: json['matchId'] as String,
        ),
      'pong' => const WsPong(),
      _ => const WsUnknown(),
    };
  }
}

class WsScoreUpdate extends WsMessage {
  final String matchId;
  final int homeScore;
  final int awayScore;
  final int? minute;
  final String status;

  const WsScoreUpdate({
    required this.matchId,
    required this.homeScore,
    required this.awayScore,
    this.minute,
    required this.status,
  });
}

class WsMatchFinished extends WsMessage {
  final String matchId;
  final int homeScore;
  final int awayScore;
  const WsMatchFinished({required this.matchId, required this.homeScore, required this.awayScore});
}

class WsRankingUpdated extends WsMessage {
  final String poolId;
  const WsRankingUpdated({required this.poolId});
}

class WsPredictionRevealed extends WsMessage {
  final String poolId;
  final String matchId;
  const WsPredictionRevealed({required this.poolId, required this.matchId});
}

class WsPong extends WsMessage {
  const WsPong();
}

class WsUnknown extends WsMessage {
  const WsUnknown();
}
