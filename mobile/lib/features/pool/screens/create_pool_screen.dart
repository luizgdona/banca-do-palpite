import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/competition_model.dart';
import '../../../core/models/match_model.dart';
import '../../../core/providers/competitions_provider.dart';
import '../../../core/providers/pools_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../competitions/screens/search_competitions_screen.dart';

class CreatePoolScreen extends ConsumerStatefulWidget {
  const CreatePoolScreen({super.key});

  @override
  ConsumerState<CreatePoolScreen> createState() => _CreatePoolScreenState();
}

class _CreatePoolScreenState extends ConsumerState<CreatePoolScreen> {
  int _step = 0;
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  CompetitionModel? _competition;
  List<MatchModel> _allMatches = [];
  final Set<String> _selectedMatchIds = {};
  int _scoringExact = 3;
  int _scoringResult = 1;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCompetition() async {
    final result = await Navigator.of(context).push<CompetitionModel>(
      MaterialPageRoute(builder: (_) => const SearchCompetitionsScreen()),
    );
    if (result == null) return;
    setState(() {
      _competition = result;
      _selectedMatchIds.clear();
      _allMatches = [];
    });
    _loadMatches(result.id);
  }

  Future<void> _loadMatches(String competitionId) async {
    try {
      final matches = await ref.read(competitionMatchesProvider(competitionId).future);
      if (!mounted) return;
      setState(() {
        _allMatches = matches
            .where((m) =>
                m.status == MatchStatus.scheduled && m.scheduledAt.isAfter(DateTime.now()))
            .toList();
      });
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().length < 3) return;
    if (_competition == null) return;
    if (_selectedMatchIds.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final pool = await ref.read(poolsProvider.notifier).create(
            name: _nameCtrl.text.trim(),
            description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
            competitionId: _competition!.id,
            matchIds: _selectedMatchIds.toList(),
            scoringExact: _scoringExact,
            scoringResult: _scoringResult,
          );
      if (!mounted) return;
      context.go('/pool/${pool.id}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        title: const Text('CRIAR BOLÃO'),
        leading: BackButton(
          color: AppColors.offWhite,
          onPressed: () => _step == 0 ? context.pop() : setState(() => _step--),
        ),
      ),
      body: Column(
        children: [
          _StepperBar(current: _step, total: 4),
          Expanded(
            child: [
              _StepName(
                nameCtrl: _nameCtrl,
                descCtrl: _descCtrl,
                onNext: () {
                  if (_nameCtrl.text.trim().length >= 3) setState(() => _step = 1);
                },
              ),
              _StepCompetition(
                selected: _competition,
                onPick: _pickCompetition,
                onNext: () {
                  if (_competition != null) setState(() => _step = 2);
                },
              ),
              _StepMatches(
                matches: _allMatches,
                selected: _selectedMatchIds,
                onToggle: (id) => setState(() {
                  if (_selectedMatchIds.contains(id)) {
                    _selectedMatchIds.remove(id);
                  } else {
                    _selectedMatchIds.add(id);
                  }
                }),
                onNext: () {
                  if (_selectedMatchIds.isNotEmpty) setState(() => _step = 3);
                },
              ),
              _StepScoring(
                exact: _scoringExact,
                result: _scoringResult,
                onExactChanged: (v) => setState(() => _scoringExact = v),
                onResultChanged: (v) => setState(() => _scoringResult = v),
                onConfirm: _isLoading ? null : _submit,
                isLoading: _isLoading,
                name: _nameCtrl.text,
                competition: _competition,
                matchCount: _selectedMatchIds.length,
              ),
            ][_step],
          ),
        ],
      ),
    );
  }
}

class _StepperBar extends StatelessWidget {
  final int current;
  final int total;
  const _StepperBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.green,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: List.generate(total, (i) {
          final done = i < current;
          final active = i == current;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: done
                    ? AppColors.amber
                    : active
                        ? AppColors.amberLight
                        : AppColors.greenLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Step 1: Nome ──────────────────────────────────────────────────────────────

class _StepName extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  final VoidCallback onNext;

  const _StepName({
    required this.nameCtrl,
    required this.descCtrl,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Como vai se chamar o bolão?',
            style: GoogleFonts.barlowCondensed(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Nome do bolão'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descrição (opcional)',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onNext,
            child: const Text('PRÓXIMO: COMPETIÇÃO'),
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Competição ────────────────────────────────────────────────────────

class _StepCompetition extends StatelessWidget {
  final CompetitionModel? selected;
  final VoidCallback onPick;
  final VoidCallback onNext;

  const _StepCompetition({
    required this.selected,
    required this.onPick,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Qual competição?',
            style: GoogleFonts.barlowCondensed(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onPick,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selected != null ? AppColors.green : AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected != null ? AppColors.amber : AppColors.divider,
                  width: 1.5,
                ),
              ),
              child: selected == null
                  ? Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.mutedDark),
                        const SizedBox(width: 12),
                        Text(
                          'Buscar competição...',
                          style: GoogleFonts.dmSans(color: AppColors.mutedDark),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        if (selected!.logoUrl != null)
                          CachedNetworkImage(
                            imageUrl: selected!.logoUrl!,
                            width: 32,
                            height: 32,
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.emoji_events_outlined,
                              color: AppColors.amber,
                            ),
                          )
                        else
                          const Icon(Icons.emoji_events_outlined, color: AppColors.amber),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selected!.name,
                                style: GoogleFonts.barlowCondensed(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.offWhite,
                                ),
                              ),
                              Text(
                                '${selected!.country ?? ''} • ${selected!.season ?? ''}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: AppColors.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.edit_outlined, color: AppColors.amberLight, size: 18),
                      ],
                    ),
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: selected != null ? onNext : null,
            child: const Text('PRÓXIMO: JOGOS'),
          ),
        ],
      ),
    );
  }
}

// ── Step 3: Jogos ─────────────────────────────────────────────────────────────

class _StepMatches extends StatelessWidget {
  final List<MatchModel> matches;
  final Set<String> selected;
  final void Function(String) onToggle;
  final VoidCallback onNext;

  const _StepMatches({
    required this.matches,
    required this.selected,
    required this.onToggle,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selecionar jogos',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              if (selected.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${selected.length} selecionados',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (matches.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'Nenhum jogo disponível\npara esta competição.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(color: AppColors.mutedDark),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: matches.length,
              itemBuilder: (context, i) {
                final match = matches[i];
                final isSelected = selected.contains(match.id);
                return GestureDetector(
                  onTap: () => onToggle(match.id),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.green : AppColors.inputFill,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.amber : AppColors.divider,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${match.homeTeam.name}  ×  ${match.awayTeam.name}',
                            style: GoogleFonts.barlowCondensed(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? AppColors.offWhite : AppColors.darkText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(match.scheduledAt),
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: isSelected ? AppColors.mutedText : AppColors.mutedDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: isSelected ? AppColors.amber : AppColors.mutedDark,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: selected.isNotEmpty ? onNext : null,
            child: const Text('PRÓXIMO: PONTUAÇÃO'),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── Step 4: Pontuação ─────────────────────────────────────────────────────────

class _StepScoring extends StatelessWidget {
  final int exact;
  final int result;
  final void Function(int) onExactChanged;
  final void Function(int) onResultChanged;
  final VoidCallback? onConfirm;
  final bool isLoading;
  final String name;
  final CompetitionModel? competition;
  final int matchCount;

  const _StepScoring({
    required this.exact,
    required this.result,
    required this.onExactChanged,
    required this.onResultChanged,
    required this.onConfirm,
    required this.isLoading,
    required this.name,
    required this.competition,
    required this.matchCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configurar pontuação',
            style: GoogleFonts.barlowCondensed(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 24),
          // Resumo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.amber,
                  ),
                ),
                Text(
                  '${competition?.name ?? ''} • $matchCount jogos',
                  style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.mutedText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _ScoringSlider(
            label: 'Placar exato',
            sublabel: 'Ex: apostou 2×1 e foi 2×1',
            value: exact,
            min: 1,
            max: 10,
            onChanged: onExactChanged,
            color: AppColors.exactColor,
          ),
          const SizedBox(height: 16),
          _ScoringSlider(
            label: 'Resultado certo',
            sublabel: 'Ex: apostou 2×1 e foi 3×0 (vitória do mesmo time)',
            value: result,
            min: 0,
            max: 10,
            onChanged: onResultChanged,
            color: AppColors.winColor,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onConfirm,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.green),
                  )
                : const Text('CRIAR BOLÃO'),
          ),
        ],
      ),
    );
  }
}

class _ScoringSlider extends StatelessWidget {
  final String label;
  final String sublabel;
  final int value;
  final int min;
  final int max;
  final void Function(int) onChanged;
  final Color color;

  const _ScoringSlider({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700, color: AppColors.darkText),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color, width: 1),
              ),
              child: Text(
                '+$value pts',
                style: GoogleFonts.barlowCondensed(
                  fontWeight: FontWeight.w800,
                  color: color,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        Text(
          sublabel,
          style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.mutedDark),
        ),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          activeColor: color,
          inactiveColor: color.withAlpha(50),
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}
