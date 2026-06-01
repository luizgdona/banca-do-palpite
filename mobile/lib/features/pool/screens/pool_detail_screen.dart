import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/models/match_model.dart';
import '../../../core/models/pool_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/pools_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../predictions/screens/predictions_screen.dart';
import '../../ranking/screens/ranking_screen.dart';

class PoolDetailScreen extends ConsumerWidget {
  final String poolId;
  const PoolDetailScreen({super.key, required this.poolId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poolAsync = ref.watch(poolDetailProvider(poolId));

    return poolAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(child: CircularProgressIndicator(color: AppColors.amber)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(child: Text(e.toString())),
      ),
      data: (pool) => _PoolDetailView(pool: pool),
    );
  }
}

class _PoolDetailView extends ConsumerStatefulWidget {
  final PoolModel pool;
  const _PoolDetailView({required this.pool});

  @override
  ConsumerState<_PoolDetailView> createState() => _PoolDetailViewState();
}

class _PoolDetailViewState extends ConsumerState<_PoolDetailView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pool = widget.pool;
    final authState = ref.watch(authProvider).valueOrNull;
    final isOwner = authState?.user?.id == pool.ownerId;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            backgroundColor: AppColors.green,
            expandedHeight: 140,
            pinned: true,
            leading: BackButton(color: AppColors.offWhite),
            actions: [
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: AppColors.offWhite),
                  onPressed: () {},
                ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: AppColors.offWhite),
                onPressed: () => _showInviteSheet(context, pool),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 56),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pool.name,
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.offWhite,
                    ),
                  ),
                  if (pool.competition != null)
                    Text(
                      pool.competition!.name,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.mutedText,
                      ),
                    ),
                ],
              ),
            ),
            bottom: TabBar(
              controller: _tabs,
              indicatorColor: AppColors.amber,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.barlowCondensed(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              labelColor: AppColors.amber,
              unselectedLabelColor: AppColors.mutedText,
              tabs: const [
                Tab(text: 'JOGOS'),
                Tab(text: 'RANKING'),
                Tab(text: 'MEMBROS'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            PredictionsScreen(pool: pool),
            RankingScreen(poolId: pool.id),
            _MembersTab(pool: pool, isOwner: isOwner),
          ],
        ),
      ),
    );
  }

  void _showInviteSheet(BuildContext context, PoolModel pool) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.green,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _InviteSheet(pool: pool),
    );
  }
}

// ── Aba Membros (mantida) ─────────────────────────────────────────────────────

class _MatchCard extends StatelessWidget {
  final MatchModel match;
  final PoolModel pool;

  const _MatchCard({required this.match, required this.pool});

  @override
  Widget build(BuildContext context) {
    final isLive = match.status == MatchStatus.live;
    final isFinished = match.status == MatchStatus.finished;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(12),
        border: isLive
            ? Border.all(color: AppColors.liveBadge, width: 1.5)
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (isLive)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.liveBadge,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '● AO VIVO${match.minute != null ? "  ${match.minute}'" : ""}',
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
              else
                Text(
                  _formatDate(match.scheduledAt),
                  style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.mutedText),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  match.homeTeam.name,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.offWhite,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (isLive || isFinished) ...[
                Text(
                  '${match.homeScore ?? 0}',
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.amber,
                  ),
                ),
                Text(
                  '  ×  ',
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 18,
                    color: AppColors.mutedText,
                  ),
                ),
                Text(
                  '${match.awayScore ?? 0}',
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.amber,
                  ),
                ),
              ] else
                Text(
                  '  ×  ',
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mutedText,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  match.awayTeam.name,
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
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

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── Aba Membros ───────────────────────────────────────────────────────────────

class _MembersTab extends ConsumerWidget {
  final PoolModel pool;
  final bool isOwner;
  const _MembersTab({required this.pool, required this.isOwner});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<dynamic>>(
      future: _fetchMembers(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.amber));
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        final members = snapshot.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: members.length,
          itemBuilder: (context, i) {
            final m = members[i] as Map<String, dynamic>;
            final user = m['user'] as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.greenMid,
                child: Text(
                  (user['name'] as String)[0].toUpperCase(),
                  style: GoogleFonts.barlowCondensed(
                    color: AppColors.amber,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              title: Text(
                user['name'] as String,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              trailing: Text(
                '${m['totalPoints'] ?? 0} pts',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<dynamic>> _fetchMembers(WidgetRef ref) async {
    final client = ref.read(apiClientProvider);
    final response = await client.dio.get('/pools/${pool.id}/members');
    return response.data as List<dynamic>;
  }
}

// ── Invite Sheet ──────────────────────────────────────────────────────────────

class _InviteSheet extends StatelessWidget {
  final PoolModel pool;
  const _InviteSheet({required this.pool});

  @override
  Widget build(BuildContext context) {
    final inviteUrl = pool.inviteUrl ?? 'bancadopalpite.app/join/${pool.inviteCode}';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mutedText,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'CONVITE',
              style: GoogleFonts.barlowCondensed(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.offWhite,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pool.name,
              style: GoogleFonts.dmSans(color: AppColors.mutedText, fontSize: 14),
            ),
            const SizedBox(height: 24),
            QrImageView(
              data: inviteUrl,
              version: QrVersions.auto,
              size: 180,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.green,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.green,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.greenMid,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                pool.inviteCode,
                style: GoogleFonts.barlowCondensed(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.amber,
                  letterSpacing: 8,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: inviteUrl));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copiado!')),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('COPIAR LINK'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.offWhite,
                      side: const BorderSide(color: AppColors.mutedText),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Share.share(
                      '⚽ Entre no meu bolão "${pool.name}"!\n\nCódigo: ${pool.inviteCode}\nLink: $inviteUrl',
                    ),
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('COMPARTILHAR'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
