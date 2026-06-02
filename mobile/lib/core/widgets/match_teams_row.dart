import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Consistent home / center / away row used in match cards and prediction cards.
///
/// The [center] widget always occupies a FIXED [centerWidth], so team names
/// never shift position regardless of whether the center shows a score, inputs,
/// or just a separator — eliminating the #1 visual inconsistency.
class MatchTeamsRow extends StatelessWidget {
  final String homeTeam;
  final String awayTeam;

  /// The center content: score text, prediction inputs, or a separator.
  final Widget center;

  /// Fixed width reserved for the center section.
  static const double centerWidth = 104.0;

  const MatchTeamsRow({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.center,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            homeTeam,
            textAlign: TextAlign.right,
            style: AppTextStyles.teamName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          width: centerWidth,
          child: Center(child: center),
        ),
        Expanded(
          child: Text(
            awayTeam,
            style: AppTextStyles.teamName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Score display for live/finished matches.
class MatchScoreDisplay extends StatelessWidget {
  final int home;
  final int away;

  const MatchScoreDisplay({super.key, required this.home, required this.away});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('$home', style: AppTextStyles.scoreMd),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '×',
            style: AppTextStyles.teamName.copyWith(
              color: AppColors.mutedText,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Text('$away', style: AppTextStyles.scoreMd),
      ],
    );
  }
}

/// Simple "×" separator for upcoming matches.
class MatchSeparator extends StatelessWidget {
  const MatchSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      '×',
      style: AppTextStyles.sectionTitle.copyWith(
        color: AppColors.mutedText,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
