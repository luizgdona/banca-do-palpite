import 'user_model.dart';

enum PredictionResult { exact, correct, wrong, pending }

PredictionResult predictionResultFromPoints(int points, int scoringExact, int scoringResult) {
  if (points == 0) return PredictionResult.wrong;
  if (points >= scoringExact) return PredictionResult.exact;
  if (points >= scoringResult) return PredictionResult.correct;
  return PredictionResult.pending;
}

class PredictionModel {
  final String? id;
  final String matchId;
  final int homeScore;
  final int awayScore;
  final int pointsEarned;
  final DateTime? updatedAt;

  const PredictionModel({
    this.id,
    required this.matchId,
    required this.homeScore,
    required this.awayScore,
    this.pointsEarned = 0,
    this.updatedAt,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) => PredictionModel(
        id: json['id'] as String?,
        matchId: json['matchId'] as String,
        homeScore: json['homeScore'] as int,
        awayScore: json['awayScore'] as int,
        pointsEarned: json['pointsEarned'] as int? ?? 0,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );
}

class MatchPredictionEntry {
  final UserModel user;
  final int homeScore;
  final int awayScore;
  final int pointsEarned;

  const MatchPredictionEntry({
    required this.user,
    required this.homeScore,
    required this.awayScore,
    required this.pointsEarned,
  });

  factory MatchPredictionEntry.fromJson(Map<String, dynamic> json) => MatchPredictionEntry(
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
        homeScore: json['homeScore'] as int,
        awayScore: json['awayScore'] as int,
        pointsEarned: json['pointsEarned'] as int? ?? 0,
      );
}

class MatchPredictionsResponse {
  final bool revealed;
  final int predictedCount;
  final int totalMembers;
  final PredictionModel? myPrediction;
  final List<MatchPredictionEntry> predictions;

  const MatchPredictionsResponse({
    required this.revealed,
    required this.predictedCount,
    required this.totalMembers,
    this.myPrediction,
    required this.predictions,
  });

  factory MatchPredictionsResponse.fromJson(Map<String, dynamic> json) =>
      MatchPredictionsResponse(
        revealed: json['revealed'] as bool,
        predictedCount: json['predictedCount'] as int,
        totalMembers: json['totalMembers'] as int,
        myPrediction: json['myPrediction'] != null
            ? PredictionModel.fromJson(
                (json['myPrediction'] as Map<String, dynamic>)
                  ..putIfAbsent('matchId', () => ''),
              )
            : null,
        predictions: (json['predictions'] as List<dynamic>)
            .map((e) => MatchPredictionEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
