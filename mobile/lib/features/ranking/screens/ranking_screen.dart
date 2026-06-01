import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                  AppSpacing.base, AppSpacing.base, AppSpacing.base,
                  myEntry != null ? 80 : AppSpacing.base),
              itemCount: entries.length,
              itemBuilder: (ctx, i) => _RankingRow(entry: entries[i]),
            ),
            if (myEntry != null && myEntry.position > 5)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: AppColors.cream,
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base, AppSpacing.sm, AppSpacing.base, AppSpacing.base),
                  child: _RankingRow(entry: myEntry, sticky: true),
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
  final bool sticky;

  const _RankingRow({required this.entry, this.sticky = false});

  static const _medalColors = [
    AppColors.exactColor,
    AppColors.silverMedal,
    AppColors.bronzeMedal,
  ];

  @override
  Widget build(BuildContext context) {
    final isTop3 = entry.position <= 3;
    final posColor = isTop3
        ? _medalColors[entry.position - 1]
        : AppColors.mutedDark;

    final bgColor = entry.isMe
        ? AppColors.amber.withAlpha(20)
        : isTop3
            ? AppColors.green.withAlpha(10)
            : Colors.transparent;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: sticky ? AppColors.inputFill : bgColor,
        borderRadius: AppSpacing.inputRadius,
        border: entry.isMe
            ? Border.all(color: AppColors.amber.withAlpha(100), width: 1.5)
            : sticky
                ? Border.all(color: AppColors.divider)
                : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '${entry.position}°',
              style: (isTop3 ? AppTextStyles.rankPositionTop : AppTextStyles.rankPosition)
                  .copyWith(color: posColor),
            ),
          ),
          AppAvatar(name: entry.user.name),
          AppSpacing.gapMdH,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.user.name,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight:
                        entry.isMe ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (entry.exactCount > 0)
                  Text(
                    '${entry.exactCount} placares exatos 🎯',
                    style: AppTextStyles.micro,
                  ),
              ],
            ),
          ),
          Text(
            '${entry.totalPoints}',
            style: AppTextStyles.rankPoints.copyWith(
              color: entry.isMe ? AppColors.amber : AppColors.darkText,
            ),
          ),
          AppSpacing.gapXs,
          Text('pts', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
