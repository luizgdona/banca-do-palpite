import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Fixed-center team row — home | 104px center | away.
/// The center is always the same width regardless of content type.
class MatchTeamsRow extends StatelessWidget {
  final String homeTeam;
  final String awayTeam;
  final Widget center;

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

/// Live/finished score display.
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
            'x',
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Text('$away', style: AppTextStyles.scoreMd),
      ],
    );
  }
}

/// Separator for upcoming matches.
class MatchSeparator extends StatelessWidget {
  const MatchSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'VS',
      style: GoogleFonts.lexend(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: AppColors.primary,
      ),
    );
  }
}
