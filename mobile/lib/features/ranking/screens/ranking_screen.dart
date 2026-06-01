import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/ranking_model.dart';
import '../../../core/providers/predictions_provider.dart';
import '../../../core/theme/app_colors.dart';

class RankingScreen extends ConsumerWidget {
  final String poolId;
  const RankingScreen({super.key, required this.poolId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(rankingProvider(poolId));

    return rankingAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.amber),
      ),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (raw) {
        final entries = raw
            .map((e) => RankingEntry.fromJson(e as Map<String, dynamic>))
            .toList();

        if (entries.isEmpty) {
          return Center(
            child: Text(
              'Nenhum ponto marcado ainda.',
              style: GoogleFonts.dmSans(color: AppColors.mutedDark),
            ),
          );
        }

        // Find "me" entry to always show at bottom if off-screen
        final myEntry = entries.where((e) => e.isMe).firstOrNull;

        return Stack(
          children: [
            ListView.builder(
              padding: EdgeInsets.fromLTRB(
                  16, 16, 16, myEntry != null ? 80 : 16),
              itemCount: entries.length,
              itemBuilder: (ctx, i) => _RankingRow(entry: entries[i]),
            ),
            // Sticky "my position" card when I'm off screen
            if (myEntry != null && myEntry.position > 5)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: AppColors.cream,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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

  @override
  Widget build(BuildContext context) {
    final isTop3 = entry.position <= 3;
    final positionColors = [
      AppColors.exactColor,   // 1°
      const Color(0xFFB0B0B0), // 2° prata
      const Color(0xFFCD7F32), // 3° bronze
    ];

    final posColor = isTop3
        ? positionColors[entry.position - 1]
        : AppColors.mutedDark;

    final bgColor = entry.isMe
        ? AppColors.amber.withAlpha(20)
        : isTop3
            ? AppColors.green.withAlpha(10)
            : Colors.transparent;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: sticky ? AppColors.inputFill : bgColor,
        borderRadius: BorderRadius.circular(10),
        border: entry.isMe
            ? Border.all(color: AppColors.amber.withAlpha(100), width: 1.5)
            : sticky
                ? Border.all(color: AppColors.divider)
                : null,
      ),
      child: Row(
        children: [
          // Position
          SizedBox(
            width: 40,
            child: Text(
              '${entry.position}°',
              style: GoogleFonts.barlowCondensed(
                fontSize: isTop3 ? 26 : 20,
                fontWeight: FontWeight.w900,
                color: posColor,
              ),
            ),
          ),
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.green,
            child: Text(
              entry.user.name[0].toUpperCase(),
              style: GoogleFonts.barlowCondensed(
                fontWeight: FontWeight.w800,
                color: AppColors.amber,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.user.name,
                  style: GoogleFonts.dmSans(
                    fontWeight:
                        entry.isMe ? FontWeight.w700 : FontWeight.w500,
                    color: AppColors.darkText,
                  ),
                ),
                if (entry.exactCount > 0)
                  Text(
                    '${entry.exactCount} placares exatos 🎯',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.mutedDark,
                    ),
                  ),
              ],
            ),
          ),
          // Points
          Text(
            '${entry.totalPoints}',
            style: GoogleFonts.barlowCondensed(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: entry.isMe ? AppColors.amber : AppColors.darkText,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'pts',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.mutedDark,
            ),
          ),
        ],
      ),
    );
  }
}
