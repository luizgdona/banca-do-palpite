import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/match_model.dart';
import '../../../core/models/pool_model.dart';
import '../../../core/providers/predictions_provider.dart';
import '../../../core/providers/realtime_provider.dart';
import '../../../core/theme/app_colors.dart';

class LiveMatchScreen extends ConsumerWidget {
  final PoolModel pool;
  final String matchId;

  const LiveMatchScreen({super.key, required this.pool, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Prefer live data from WS provider — updates in real time
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
          // Scoreboard
          _ScoreBoard(match: match),
          const SizedBox(height: 8),
          // Predictions list
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: predictionsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.amber),
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          if (isLive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.liveBadge,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '● AO VIVO${match.minute != null ? "  ${match.minute}'" : ""}',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  match.homeTeam.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.offWhite,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${match.homeScore ?? 0}',
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: AppColors.amber,
                        height: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '×',
                        style: GoogleFonts.barlowCondensed(
                          fontSize: 32,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ),
                    Text(
                      '${match.awayScore ?? 0}',
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: AppColors.amber,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  match.awayTeam.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Text(
                  'PALPITES',
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.green.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$predictedCount de $totalMembers apostaram',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.mutedDark,
                    ),
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
                  const SizedBox(height: 12),
                  Text(
                    'Palpites revelados\nquando o jogo começar',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(color: AppColors.mutedDark),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final p = predictions[i] as dynamic;
                  final pts = p.pointsEarned as int;
                  final isExact = pts >= pool.scoringExact;
                  final isCorrect = pts >= pool.scoringResult && pts < pool.scoringExact;

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
                    badge =
                        '${p.homeScore} × ${p.awayScore}';
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: badgeColor.withAlpha(80), width: 1),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.green,
                          child: Text(
                            (p.user.name as String)[0].toUpperCase(),
                            style: GoogleFonts.barlowCondensed(
                              color: AppColors.amber,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            p.user.name as String,
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                        Text(
                          '${p.homeScore} × ${p.awayScore}',
                          style: GoogleFonts.barlowCondensed(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: badgeColor),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.barlowCondensed(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
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
