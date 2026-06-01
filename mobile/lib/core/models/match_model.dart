class TeamInfo {
  final int? id;
  final String name;
  final String? logo;

  const TeamInfo({this.id, required this.name, this.logo});

  factory TeamInfo.fromJson(Map<String, dynamic> json) => TeamInfo(
        id: json['id'] as int?,
        name: json['name'] as String,
        logo: json['logo'] as String?,
      );
}

enum MatchStatus { scheduled, live, finished, postponed, cancelled }

MatchStatus matchStatusFromString(String s) {
  return MatchStatus.values.firstWhere(
    (e) => e.name == s,
    orElse: () => MatchStatus.scheduled,
  );
}

class MatchModel {
  final String id;
  final TeamInfo homeTeam;
  final TeamInfo awayTeam;
  final DateTime scheduledAt;
  final MatchStatus status;
  final int? homeScore;
  final int? awayScore;
  final int? minute;
  final String? period;

  const MatchModel({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.scheduledAt,
    required this.status,
    this.homeScore,
    this.awayScore,
    this.minute,
    this.period,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) => MatchModel(
        id: json['id'] as String,
        homeTeam: TeamInfo.fromJson(json['homeTeam'] as Map<String, dynamic>),
        awayTeam: TeamInfo.fromJson(json['awayTeam'] as Map<String, dynamic>),
        scheduledAt: DateTime.parse(json['scheduledAt'] as String),
        status: matchStatusFromString(json['status'] as String),
        homeScore: json['homeScore'] as int?,
        awayScore: json['awayScore'] as int?,
        minute: json['minute'] as int?,
        period: json['period'] as String?,
      );

  bool get isLocked =>
      status == MatchStatus.live ||
      status == MatchStatus.finished ||
      DateTime.now().isAfter(scheduledAt);
}
