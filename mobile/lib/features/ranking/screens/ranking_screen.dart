import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/ranking_model.dart';
import '../../../core/providers/predictions_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_loading.dart';

class RankingScreen extends ConsumerWidget {
  final String poolId;
  const RankingScreen({super.key, required this.poolId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(rankingProvider(poolId));

    return rankingAsync.when(
      loading: () => const AppLoadingIndicator(),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (raw) {
        final entries = raw
            .map((e) => RankingEntry.fromJson(e as Map<String, dynamic>))
            .toList();

        if (entries.isEmpty) {
          return Center(
            child: Text(
              'Nenhum ponto marcado ainda.',
              style: AppTextStyles.bodySm,
            ),
          );
        }

        final myEntry = entries.where((e) => e.isMe).firstOrNull;

        return Stack(
          children: [
            ListView.builder(
              padding: EdgeInsets.fromLTRB(
                0, AppSpacing.sm, 0,
                myEntry != null ? 80 : AppSpacing.base,
              ),
              itemCount: entries.length,
              itemBuilder: (ctx, i) => _RankingRow(
                entry: entries[i],
                rank: i + 1,
              ),
            ),
            if (myEntry != null && myEntry.position > 5)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.fromLTRB(
                    0, AppSpacing.xs, 0, AppSpacing.base),
                  child: _RankingRow(entry: myEntry, rank: myEntry.position, sticky: true),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RankingRow extends StatelessWidget {
  final RankingEntry entry;
  final int rank;
  final bool sticky;

  const _RankingRow({required this.entry, required this.rank, this.sticky = false});

  static const _medalColors = [
    AppColors.goldMedal,
    AppColors.silverMedal,
    AppColors.bronzeMedal,
  ];

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    final isFirst = rank == 1;
    final posColor = isTop3 ? _medalColors[rank - 1] : AppColors.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: isFirst && !sticky
            ? AppColors.secondary.withAlpha(15)
            : entry.isMe
                ? AppColors.primary.withAlpha(10)
                : (sticky ? AppColors.surfaceContainerHigh : AppColors.background),
        border: entry.isMe
            ? Border(
                left: BorderSide(color: AppColors.primary, width: 3),
                bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5),
              )
            : Border(
                bottom: BorderSide(
                  color: AppColors.outlineVariant.withAlpha(40),
                  width: 0.5,
                ),
              ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // Position — fixed width
          SizedBox(
            width: 36,
            child: Text(
              '$rank.',
              style: GoogleFonts.lexend(
                fontSize: isTop3 ? 20 : 16,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: posColor,
              ),
            ),
          ),
          // Avatar
          AppAvatar(
            name: entry.user.name,
            backgroundColor: isFirst
                ? AppColors.secondary.withAlpha(30)
                : AppColors.surfaceContainerHighest,
            textColor: isFirst ? AppColors.secondary : AppColors.primary,
          ),
          AppSpacing.gapMdH,
          // Name + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.user.name,
                  style: AppTextStyles.memberName.copyWith(
                    fontWeight:
                        entry.isMe ? FontWeight.w700 : FontWeight.w500,
                    color: entry.isMe ? AppColors.primary : AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.exactCount > 0)
                  Text(
                    '${entry.exactCount} placares exatos',
                    style: AppTextStyles.micro.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
              ],
            ),
          ),
          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${entry.totalPoints}',
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: entry.isMe
                      ? AppColors.primary
                      : isFirst
                          ? AppColors.secondary
                          : AppColors.onSurface,
                ),
              ),
              Text('pts', style: AppTextStyles.micro),
            ],
          ),
        ],
      ),
    );
  }
}
