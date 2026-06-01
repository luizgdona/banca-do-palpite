import 'user_model.dart';

class RankingEntry {
  final int position;
  final UserModel user;
  final int totalPoints;
  final int exactCount;
  final bool isMe;

  const RankingEntry({
    required this.position,
    required this.user,
    required this.totalPoints,
    required this.exactCount,
    required this.isMe,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) => RankingEntry(
        position: json['position'] as int,
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
        totalPoints: json['totalPoints'] as int,
        exactCount: json['exactCount'] as int? ?? 0,
        isMe: json['isMe'] as bool? ?? false,
      );
}
