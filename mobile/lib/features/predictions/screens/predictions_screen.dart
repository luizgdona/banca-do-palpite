import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/match_model.dart';
import '../../../core/models/pool_model.dart';
import '../../../core/models/prediction_model.dart';
import '../../../core/providers/predictions_provider.dart';
import '../../../core/theme/app_colors.dart';

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
    final matches = widget.pool.poolMatches.map((pm) => pm.match).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    // Group by date
    final groups = <String, List<MatchModel>>{};
    for (final m in matches) {
      final key =
          '${m.scheduledAt.day.toString().padLeft(2, '0')}/${m.scheduledAt.month.toString().padLeft(2, '0')}';
      groups.putIfAbsent(key, () => []).add(m);
    }

    return predictionsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.amber),
      ),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (predictions) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final entry in groups.entries) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                entry.key,
                style: GoogleFonts.barlowCondensed(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedDark,
                  letterSpacing: 1,
                ),
              ),
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

    return GestureDetector(
      onTap: (isLive || isFinished)
          ? () => context.push(
                '/pool/${widget.pool.id}/match/${match.id}',
                extra: widget.pool,
              )
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(12),
          border: isLive ? Border.all(color: AppColors.liveBadge, width: 1.5) : null,
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                children: [
                  if (isLive)
                    _LiveBadge(minute: match.minute)
                  else
                    Text(
                      _formatTime(match.scheduledAt),
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.mutedText,
                      ),
                    ),
                  const Spacer(),
                  _SaveIndicator(state: _saveState, locked: locked),
                ],
              ),
            ),
            // Score row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  // Home team
                  Expanded(
                    child: Text(
                      match.homeTeam.name,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.offWhite,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Real score (if live/finished)
                  if (isLive || isFinished) ...[
                    _RealScoreDisplay(
                      home: match.homeScore ?? 0,
                      away: match.awayScore ?? 0,
                    ),
                  ] else ...[
                    // Prediction inputs
                    _ScoreInput(
                      controller: _homeCtrl,
                      enabled: !locked,
                      onChanged: (_) => _onChanged(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '×',
                        style: GoogleFonts.barlowCondensed(
                          fontSize: 20,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ),
                    _ScoreInput(
                      controller: _awayCtrl,
                      enabled: !locked,
                      onChanged: (_) => _onChanged(),
                    ),
                  ],
                  const SizedBox(width: 10),
                  // Away team
                  Expanded(
                    child: Text(
                      match.awayTeam.name,
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.offWhite,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Prediction recap when locked
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
        style: GoogleFonts.barlowCondensed(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: enabled ? AppColors.amber : AppColors.mutedText,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: enabled ? AppColors.greenMid : AppColors.green,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.greenLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.amber, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.greenLight),
          ),
        ),
      ),
    );
  }
}

class _RealScoreDisplay extends StatelessWidget {
  final int home;
  final int away;
  const _RealScoreDisplay({required this.home, required this.away});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$home',
          style: GoogleFonts.barlowCondensed(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppColors.amber,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '×',
            style: GoogleFonts.barlowCondensed(
              fontSize: 20,
              color: AppColors.mutedText,
            ),
          ),
        ),
        Text(
          '$away',
          style: GoogleFonts.barlowCondensed(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppColors.amber,
          ),
        ),
      ],
    );
  }
}

class _PredictionRecap extends StatelessWidget {
  final PredictionModel prediction;
  const _PredictionRecap({required this.prediction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
      child: Row(
        children: [
          Text(
            'Seu palpite: ${prediction.homeScore} × ${prediction.awayScore}',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.mutedText,
            ),
          ),
          const Spacer(),
          if (prediction.pointsEarned > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: prediction.pointsEarned >= 3
                    ? AppColors.exactColor.withAlpha(30)
                    : AppColors.winColor.withAlpha(30),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: prediction.pointsEarned >= 3
                      ? AppColors.exactColor
                      : AppColors.winColor,
                ),
              ),
              child: Text(
                '+${prediction.pointsEarned} pts',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: prediction.pointsEarned >= 3
                      ? AppColors.exactColor
                      : AppColors.winColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatefulWidget {
  final int? minute;
  const _LiveBadge({this.minute});

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(_pulse);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.liveBadge,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '● AO VIVO${widget.minute != null ? "  ${widget.minute}'" : ""}',
          style: GoogleFonts.barlowCondensed(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
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
          Text(
            'encerrado',
            style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.mutedText),
          ),
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
            Text(
              'salvando...',
              style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.mutedText),
            ),
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
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppColors.winColor,
              ),
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
              style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.liveBadge),
            ),
          ],
        ),
    };
  }
}

enum _SaveState { idle, pending, saved, error }
