import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/match_model.dart';
import '../../../core/models/pool_model.dart';
import '../../../core/models/prediction_model.dart';
import '../../../core/providers/predictions_provider.dart';
import '../../../core/providers/realtime_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_live_badge.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/match_teams_row.dart';

class PredictionsScreen extends ConsumerStatefulWidget {
  final PoolModel pool;
  const PredictionsScreen({super.key, required this.pool});

  @override
  ConsumerState<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends ConsumerState<PredictionsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(predictionsProvider.notifier).loadForPool(widget.pool.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final predictionsAsync = ref.watch(predictionsProvider);
    // Use live data from WS provider if available, fall back to pool snapshot
    final liveMap = ref.watch(liveMatchesProvider).valueOrNull ?? {};
    final matches = widget.pool.poolMatches
        .map((pm) => liveMap[pm.match.id] ?? pm.match)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    // Group by date
    final groups = <String, List<MatchModel>>{};
    for (final m in matches) {
      final key =
          '${m.scheduledAt.day.toString().padLeft(2, '0')}/${m.scheduledAt.month.toString().padLeft(2, '0')}';
      groups.putIfAbsent(key, () => []).add(m);
    }

    return predictionsAsync.when(
      loading: () => const AppLoadingIndicator(),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (predictions) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final entry in groups.entries) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(entry.key, style: AppTextStyles.tabLabel),
            ),
            for (final match in entry.value)
              _PredictionCard(
                key: ValueKey(match.id),
                match: match,
                prediction: predictions[match.id],
                pool: widget.pool,
              ),
          ],
        ],
      ),
    );
  }
}

class _PredictionCard extends ConsumerStatefulWidget {
  final MatchModel match;
  final PredictionModel? prediction;
  final PoolModel pool;

  const _PredictionCard({
    super.key,
    required this.match,
    required this.prediction,
    required this.pool,
  });

  @override
  ConsumerState<_PredictionCard> createState() => _PredictionCardState();
}

class _PredictionCardState extends ConsumerState<_PredictionCard> {
  late final TextEditingController _homeCtrl;
  late final TextEditingController _awayCtrl;
  Timer? _debounce;
  _SaveState _saveState = _SaveState.idle;

  @override
  void initState() {
    super.initState();
    _homeCtrl = TextEditingController(
      text: widget.prediction?.homeScore.toString() ?? '',
    );
    _awayCtrl = TextEditingController(
      text: widget.prediction?.awayScore.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _homeCtrl.dispose();
    _awayCtrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    _debounce?.cancel();
    final h = int.tryParse(_homeCtrl.text);
    final a = int.tryParse(_awayCtrl.text);
    if (h == null || a == null) return;

    setState(() => _saveState = _SaveState.pending);

    _debounce = Timer(const Duration(milliseconds: 800), () async {
      try {
        await ref.read(predictionsProvider.notifier).save(widget.match.id, h, a);
        if (mounted) setState(() => _saveState = _SaveState.saved);
        // Reset to idle after a moment
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _saveState = _SaveState.idle);
        });
      } catch (e) {
        if (mounted) setState(() => _saveState = _SaveState.error);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final locked = match.isLocked;
    final isLive = match.status == MatchStatus.live;
    final isFinished = match.status == MatchStatus.finished;

    return AppCard(
        borderColor: isLive ? AppColors.liveBadge : null,
        onTap: (isLive || isFinished)
            ? () => context.push(
                  '/pool/${widget.pool.id}/match/${match.id}',
                  extra: widget.pool,
                )
            : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.base, AppSpacing.md,
            AppSpacing.base, AppSpacing.base,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header — fixed height for stable layout ──
              SizedBox(
                height: 22,
                child: Row(
                  children: [
                    if (isLive)
                      AppLiveBadge(minute: match.minute)
                    else
                      Text(
                        _formatTime(match.scheduledAt),
                        style: AppTextStyles.micro,
                      ),
                    const Spacer(),
                    _SaveIndicator(state: _saveState, locked: locked),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // ── Teams row with fixed center ──
              MatchTeamsRow(
                homeTeam: match.homeTeam.name,
                awayTeam: match.awayTeam.name,
                center: (isLive || isFinished)
                    ? MatchScoreDisplay(
                        home: match.homeScore ?? 0,
                        away: match.awayScore ?? 0,
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _ScoreInput(
                            controller: _homeCtrl,
                            enabled: !locked,
                            onChanged: (_) => _onChanged(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                            ),
                            child: Text(
                              '×',
                              style: AppTextStyles.teamName.copyWith(
                                color: AppColors.mutedText,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          _ScoreInput(
                            controller: _awayCtrl,
                            enabled: !locked,
                            onChanged: (_) => _onChanged(),
                          ),
                        ],
                      ),
              ),
              // ── Prediction recap (locked/finished) ──
              if (locked && widget.prediction != null)
                _PredictionRecap(prediction: widget.prediction!),
            ],
          ),
        ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ScoreInput extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final void Function(String) onChanged;

  const _ScoreInput({
    required this.controller,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: TextField(
        controller: controller,
        enabled: enabled,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 2,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        style: AppTextStyles.scoreLg.copyWith(
          fontSize: 24,
          color: enabled ? AppColors.amber : AppColors.mutedText,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: enabled ? AppColors.greenMid : AppColors.green,
          enabledBorder: const OutlineInputBorder(
            borderRadius: AppSpacing.inputRadius,
            borderSide: BorderSide(color: AppColors.greenLight),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: AppSpacing.inputRadius,
            borderSide: BorderSide(color: AppColors.amber, width: 2),
          ),
          disabledBorder: const OutlineInputBorder(
            borderRadius: AppSpacing.inputRadius,
            borderSide: BorderSide(color: AppColors.greenLight),
          ),
        ),
      ),
    );
  }
}


class _PredictionRecap extends StatelessWidget {
  final PredictionModel prediction;
  const _PredictionRecap({required this.prediction});

  @override
  Widget build(BuildContext context) {
    final pointColor = prediction.pointsEarned >= 3
        ? AppColors.exactColor
        : AppColors.winColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            'Seu palpite: ${prediction.homeScore} × ${prediction.awayScore}',
            style: AppTextStyles.caption,
          ),
          const Spacer(),
          if (prediction.pointsEarned > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs / 2),
              decoration: BoxDecoration(
                color: pointColor.withAlpha(30),
                borderRadius: AppSpacing.badgeRadius,
                border: Border.all(color: pointColor),
              ),
              child: Text(
                '+${prediction.pointsEarned} pts',
                style: AppTextStyles.tabLabel.copyWith(
                  fontSize: 13,
                  color: pointColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}


class _SaveIndicator extends StatelessWidget {
  final _SaveState state;
  final bool locked;

  const _SaveIndicator({required this.state, required this.locked});

  @override
  Widget build(BuildContext context) {
    if (locked) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 12, color: AppColors.mutedText),
          const SizedBox(width: 4),
          Text('encerrado', style: AppTextStyles.micro),
        ],
      );
    }
    return switch (state) {
      _SaveState.idle => const SizedBox.shrink(),
      _SaveState.pending => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppColors.amberLight,
              ),
            ),
            const SizedBox(width: 4),
            Text('salvando...', style: AppTextStyles.micro),
          ],
        ),
      _SaveState.saved => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 12, color: AppColors.winColor),
            const SizedBox(width: 4),
            Text(
              'palpite salvo',
              style: AppTextStyles.micro.copyWith(color: AppColors.winColor),
            ),
          ],
        ),
      _SaveState.error => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 12, color: AppColors.liveBadge),
            const SizedBox(width: 4),
            Text(
              'erro',
              style: AppTextStyles.micro.copyWith(color: AppColors.liveBadge),
            ),
          ],
        ),
    };
  }
}

enum _SaveState { idle, pending, saved, error }
