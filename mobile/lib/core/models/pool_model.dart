import 'competition_model.dart';
import 'match_model.dart';
import 'user_model.dart';

class PoolMatch {
  final MatchModel match;
  const PoolMatch({required this.match});

  factory PoolMatch.fromJson(Map<String, dynamic> json) =>
      PoolMatch(match: MatchModel.fromJson(json['match'] as Map<String, dynamic>));
}

class PoolCount {
  final int members;
  final int poolMatches;

  const PoolCount({required this.members, required this.poolMatches});

  factory PoolCount.fromJson(Map<String, dynamic> json) => PoolCount(
        members: json['members'] as int? ?? 0,
        poolMatches: json['poolMatches'] as int? ?? 0,
      );
}

class PoolModel {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final String inviteCode;
  final String? inviteUrl;
  final int scoringExact;
  final int scoringResult;
  final bool isPublic;
  final String status;
  final DateTime createdAt;
  final UserModel? owner;
  final CompetitionModel? competition;
  final PoolCount? count;
  final List<PoolMatch> poolMatches;

  const PoolModel({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    required this.inviteCode,
    this.inviteUrl,
    required this.scoringExact,
    required this.scoringResult,
    required this.isPublic,
    required this.status,
    required this.createdAt,
    this.owner,
    this.competition,
    this.count,
    this.poolMatches = const [],
  });

  factory PoolModel.fromJson(Map<String, dynamic> json) => PoolModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        ownerId: json['ownerId'] as String,
        inviteCode: json['inviteCode'] as String,
        inviteUrl: json['inviteUrl'] as String?,
        scoringExact: json['scoringExact'] as int? ?? 3,
        scoringResult: json['scoringResult'] as int? ?? 1,
        isPublic: json['isPublic'] as bool? ?? false,
        status: json['status'] as String? ?? 'open',
        createdAt: DateTime.parse(json['createdAt'] as String),
        owner: json['owner'] != null
            ? UserModel.fromJson(json['owner'] as Map<String, dynamic>)
            : null,
        competition: json['competition'] != null
            ? CompetitionModel.fromJson(json['competition'] as Map<String, dynamic>)
            : null,
        count: json['_count'] != null
            ? PoolCount.fromJson(json['_count'] as Map<String, dynamic>)
            : null,
        poolMatches: (json['poolMatches'] as List<dynamic>?)
                ?.map((e) => PoolMatch.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class PoolPreview {
  final String id;
  final String name;
  final String? description;
  final String inviteCode;
  final String status;
  final UserModel? owner;
  final CompetitionModel? competition;
  final int memberCount;

  const PoolPreview({
    required this.id,
    required this.name,
    this.description,
    required this.inviteCode,
    required this.status,
    this.owner,
    this.competition,
    required this.memberCount,
  });

  factory PoolPreview.fromJson(Map<String, dynamic> json) => PoolPreview(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        inviteCode: json['inviteCode'] as String,
        status: json['status'] as String? ?? 'open',
        owner: json['owner'] != null
            ? UserModel.fromJson(json['owner'] as Map<String, dynamic>)
            : null,
        competition: json['competition'] != null
            ? CompetitionModel.fromJson(json['competition'] as Map<String, dynamic>)
            : null,
        memberCount: (json['_count'] as Map<String, dynamic>?)?['members'] as int? ?? 0,
      );
}
