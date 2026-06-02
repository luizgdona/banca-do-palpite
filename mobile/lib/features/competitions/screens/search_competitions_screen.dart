import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/competition_model.dart';
import '../../../core/providers/competitions_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_loading.dart';

class SearchCompetitionsScreen extends ConsumerStatefulWidget {
  const SearchCompetitionsScreen({super.key});

  @override
  ConsumerState<SearchCompetitionsScreen> createState() =>
      _SearchCompetitionsScreenState();
}

class _SearchCompetitionsScreenState
    extends ConsumerState<SearchCompetitionsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final competitionsAsync =
        ref.watch(competitionsProvider(_query.isEmpty ? null : _query));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ESCOLHER COMPETIÇÃO'),
        backgroundColor: AppColors.surfaceContainerLow,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surfaceContainerLow,
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, 0, AppSpacing.base, AppSpacing.base),
            child: TextField(
              controller: _searchCtrl,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Buscar competição...',
                hintStyle:
                    AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                filled: true,
                fillColor: AppColors.surfaceContainerHighest,
                border: const OutlineInputBorder(
                  borderRadius: AppSpacing.inputRadius,
                  borderSide: BorderSide.none,
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: AppSpacing.inputRadius,
                  borderSide: BorderSide.none,
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: AppSpacing.inputRadius,
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: (v) {
                Future.delayed(const Duration(milliseconds: 400), () {
                  if (mounted && v == _searchCtrl.text) {
                    setState(() => _query = v.trim());
                  }
                });
              },
            ),
          ),
          Expanded(
            child: competitionsAsync.when(
              loading: () => const AppLoadingIndicator(),
              error: (e, _) => Center(
                child: Text('Erro ao carregar competições',
                    style: AppTextStyles.bodyMd),
              ),
              data: (competitions) => competitions.isEmpty
                  ? Center(
                      child: Text('Nenhuma competição encontrada',
                          style: AppTextStyles.bodySm),
                    )
                  : ListView.builder(
                      padding: AppSpacing.pageVertical,
                      itemCount: competitions.length,
                      itemBuilder: (context, i) =>
                          _CompetitionTile(competition: competitions[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompetitionTile extends StatelessWidget {
  final CompetitionModel competition;
  const _CompetitionTile({required this.competition});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceContainerHigh,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: () => Navigator.of(context).pop(competition),
        leading: competition.logoUrl != null
            ? CachedNetworkImage(
                imageUrl: competition.logoUrl!,
                width: 36,
                height: 36,
                errorWidget: (_, __, ___) => const Icon(
                  Icons.emoji_events_outlined,
                  color: AppColors.secondary,
                ),
              )
            : const Icon(Icons.emoji_events_outlined, color: AppColors.secondary),
        title: Text(competition.name, style: AppTextStyles.cardTitle),
        subtitle: Text(
          '${competition.country ?? ''} • ${competition.season ?? ''}',
          style: AppTextStyles.caption,
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
      ),
    );
  }
}
