import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/models/match_model.dart';
import '../../../core/models/pool_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/pools_provider.dart';
import '../../../core/providers/realtime_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_live_badge.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/match_teams_row.dart';
import '../../predictions/screens/predictions_screen.dart';
import '../../ranking/screens/ranking_screen.dart';

class PoolDetailScreen extends ConsumerWidget {
  final String poolId;
  const PoolDetailScreen({super.key, required this.poolId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poolAsync = ref.watch(poolDetailProvider(poolId));

    return poolAsync.when(
      loading: () => const AppLoadingScaffold(),
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
    // Seed live matches and connect to WebSocket for this pool
    Future.microtask(() {
      final pool = widget.pool;
      final matches = pool.poolMatches.map((pm) => pm.match).toList();
      ref.read(liveMatchesProvider.notifier).initForPool(pool.id, matches);
    });
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
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            backgroundColor: AppColors.surfaceContainerLow,
            expandedHeight: 140,
            pinned: true,
            leading: BackButton(color: AppColors.primary),
            actions: [
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: AppColors.onSurfaceVariant),
                  onPressed: () {},
                ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: AppColors.onSurfaceVariant),
                onPressed: () => _showInviteSheet(context, pool),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 56),
              background: Container(color: AppColors.surfaceContainerLow),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pool.name,
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontSize: 20,
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (pool.competition != null)
                    Text(
                      pool.competition!.name,
                      style: AppTextStyles.caption,
                    ),
                ],
              ),
            ),
            bottom: TabBar(
              controller: _tabs,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.onSurfaceVariant,
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
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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

    return AppCard(
      borderColor: isLive ? AppColors.liveBadge : null,
      onTap: (isLive || isFinished)
          ? () => Navigator.of(context).pushNamed(
                '/pool/${match.id}',
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
            // ── Status row — fixed height keeps card proportions stable ──
            SizedBox(
              height: 22,
              child: Row(
                children: [
                  if (isLive)
                    AppLiveBadge(minute: match.minute)
                  else
                    Text(
                      _formatDate(match.scheduledAt),
                      style: AppTextStyles.micro,
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // ── Teams row — fixed-width center prevents shifting ──
            MatchTeamsRow(
              homeTeam: match.homeTeam.name,
              awayTeam: match.awayTeam.name,
              center: (isLive || isFinished)
                  ? MatchScoreDisplay(
                      home: match.homeScore ?? 0,
                      away: match.awayScore ?? 0,
                    )
                  : const MatchSeparator(),
            ),
          ],
        ),
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
          return const AppLoadingIndicator();
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
              leading: AppAvatar(
                name: user['name'] as String,
                backgroundColor: AppColors.greenMid,
              ),
              title: Text(
                user['name'] as String,
                style: AppTextStyles.memberName,
              ),
              trailing: Text(
                '${m['totalPoints'] ?? 0} pts',
                style: AppTextStyles.tabLabel.copyWith(
                  fontSize: 16,
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
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AppSpacing.gapLg,
            Text('CONVITE', style: AppTextStyles.sectionTitle.copyWith(fontSize: 20)),
            AppSpacing.gapXs,
            Text(pool.name, style: AppTextStyles.bodySm),
            AppSpacing.gapXl,
            QrImageView(
              data: inviteUrl,
              version: QrVersions.auto,
              size: 180,
              backgroundColor: AppColors.onSurface,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.background,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.background,
              ),
            ),
            AppSpacing.gapLg,
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: AppSpacing.inputRadius,
                border: Border.all(color: AppColors.primary.withAlpha(60)),
              ),
              child: Text(pool.inviteCode, style: AppTextStyles.inviteCode),
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
