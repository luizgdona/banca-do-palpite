import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/match_model.dart';
import '../../../core/models/pool_model.dart';
import '../../../core/providers/predictions_provider.dart';
import '../../../core/providers/realtime_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_live_badge.dart';
import '../../../core/widgets/app_loading.dart';

class LiveMatchScreen extends ConsumerWidget {
  final PoolModel pool;
  final String matchId;

  const LiveMatchScreen({super.key, required this.pool, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveMap = ref.watch(liveMatchesProvider).valueOrNull ?? {};
    final match = liveMap[matchId] ??
        pool.poolMatches
            .map((pm) => pm.match)
            .where((m) => m.id == matchId)
            .firstOrNull;

    if (match == null) {
      return const Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(child: Text('Jogo não encontrado')),
      );
    }

    final predictionsAsync = ref.watch(
      matchPredictionsProvider((poolId: pool.id, matchId: matchId)),
    );

    return Scaffold(
      backgroundColor: AppColors.green,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        elevation: 0,
        leading: BackButton(color: AppColors.offWhite),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.offWhite),
            onPressed: () => ref.invalidate(
              matchPredictionsProvider((poolId: pool.id, matchId: matchId)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _ScoreBoard(match: match),
          AppSpacing.gapSm,
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusXl),
                ),
              ),
              child: predictionsAsync.when(
                loading: () => const AppLoadingIndicator(),
                error: (e, _) => Center(child: Text(e.toString())),
                data: (data) => _PredictionsList(
                  data: data,
                  match: match,
                  pool: pool,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBoard extends StatelessWidget {
  final MatchModel match;
  const _ScoreBoard({required this.match});

  @override
  Widget build(BuildContext context) {
    final isLive = match.status == MatchStatus.live;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
      child: Column(
        children: [
          if (isLive)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.base),
              child: AppLiveBadge(minute: match.minute),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  match.homeTeam.name,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: AppColors.offWhite,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${match.homeScore ?? 0}',
                      style: AppTextStyles.scoreXl,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm),
                      child: Text(
                        '×',
                        style: AppTextStyles.scoreLg.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                    ),
                    Text(
                      '${match.awayScore ?? 0}',
                      style: AppTextStyles.scoreXl,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  match.awayTeam.name,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: AppColors.offWhite,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PredictionsList extends StatelessWidget {
  final dynamic data;
  final MatchModel match;
  final PoolModel pool;

  const _PredictionsList({
    required this.data,
    required this.match,
    required this.pool,
  });

  @override
  Widget build(BuildContext context) {
    final isRevealed = data.revealed as bool;
    final predictedCount = data.predictedCount as int;
    final totalMembers = data.totalMembers as int;
    final predictions = data.predictions as List;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
            child: Row(
              children: [
                Text(
                  'PALPITES',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm + 2, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.green.withAlpha(20),
                    borderRadius: AppSpacing.chipRadius,
                  ),
                  child: Text(
                    '$predictedCount de $totalMembers apostaram',
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isRevealed)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_clock,
                      size: 40, color: AppColors.mutedDark),
                  AppSpacing.gapMd,
                  Text(
                    'Palpites revelados\nquando o jogo começar',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySm,
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: AppSpacing.pagePadding,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final p = predictions[i] as dynamic;
                  final pts = p.pointsEarned as int;
                  final isExact = pts >= pool.scoringExact;
                  final isCorrect =
                      pts >= pool.scoringResult && pts < pool.scoringExact;

                  Color cardColor;
                  Color badgeColor;
                  String badge;

                  if (pts == 0 && match.status == MatchStatus.finished) {
                    cardColor = AppColors.lossColor.withAlpha(20);
                    badgeColor = AppColors.lossColor;
                    badge = '0 pts';
                  } else if (isExact) {
                    cardColor = AppColors.exactColor.withAlpha(20);
                    badgeColor = AppColors.exactColor;
                    badge = '+$pts pts 🎯';
                  } else if (isCorrect) {
                    cardColor = AppColors.winColor.withAlpha(20);
                    badgeColor = AppColors.winColor;
                    badge = '+$pts pts';
                  } else {
                    cardColor = AppColors.inputFill;
                    badgeColor = AppColors.mutedDark;
                    badge = '${p.homeScore} × ${p.awayScore}';
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: AppSpacing.inputRadius,
                      border: Border.all(
                          color: badgeColor.withAlpha(80), width: 1),
                    ),
                    child: Row(
                      children: [
                        AppAvatar(name: p.user.name as String),
                        AppSpacing.gapMdH,
                        Expanded(
                          child: Text(
                            p.user.name as String,
                            style: AppTextStyles.memberName,
                          ),
                        ),
                        Text(
                          '${p.homeScore} × ${p.awayScore}',
                          style: AppTextStyles.teamName.copyWith(
                            fontSize: 18,
                            color: AppColors.darkText,
                          ),
                        ),
                        AppSpacing.gapSmH,
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs / 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withAlpha(30),
                            borderRadius: AppSpacing.badgeRadius,
                            border: Border.all(color: badgeColor),
                          ),
                          child: Text(
                            badge,
                            style: AppTextStyles.tabLabel.copyWith(
                              fontSize: 13,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: predictions.length,
              ),
            ),
          ),
      ],
    );
  }
}
