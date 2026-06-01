import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/competition_model.dart';
import '../../../core/providers/competitions_provider.dart';
import '../../../core/theme/app_colors.dart';

class SearchCompetitionsScreen extends ConsumerStatefulWidget {
  const SearchCompetitionsScreen({super.key});

  @override
  ConsumerState<SearchCompetitionsScreen> createState() => _SearchCompetitionsScreenState();
}

class _SearchCompetitionsScreenState extends ConsumerState<SearchCompetitionsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final competitionsAsync = ref.watch(competitionsProvider(_query.isEmpty ? null : _query));

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('ESCOLHER COMPETIÇÃO'),
        backgroundColor: AppColors.green,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.green,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchCtrl,
              style: GoogleFonts.dmSans(color: AppColors.offWhite),
              decoration: InputDecoration(
                hintText: 'Buscar competição...',
                hintStyle: GoogleFonts.dmSans(color: AppColors.mutedText),
                prefixIcon: const Icon(Icons.search, color: AppColors.mutedText),
                filled: true,
                fillColor: AppColors.greenMid,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.amber, width: 2),
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
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.amber),
              ),
              error: (e, _) => Center(
                child: Text('Erro ao carregar competições',
                    style: GoogleFonts.dmSans(color: AppColors.darkText)),
              ),
              data: (competitions) => competitions.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhuma competição encontrada',
                        style: GoogleFonts.dmSans(color: AppColors.mutedDark),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
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
      color: AppColors.green,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => Navigator.of(context).pop(competition),
        leading: competition.logoUrl != null
            ? CachedNetworkImage(
                imageUrl: competition.logoUrl!,
                width: 36,
                height: 36,
                errorWidget: (_, __, ___) => const Icon(
                  Icons.emoji_events_outlined,
                  color: AppColors.amber,
                ),
              )
            : const Icon(Icons.emoji_events_outlined, color: AppColors.amber),
        title: Text(
          competition.name,
          style: GoogleFonts.barlowCondensed(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.offWhite,
          ),
        ),
        subtitle: Text(
          '${competition.country ?? ''} • ${competition.season ?? ''}',
          style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.mutedText),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.mutedText),
      ),
    );
  }
}
