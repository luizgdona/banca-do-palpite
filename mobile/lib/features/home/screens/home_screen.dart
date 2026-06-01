import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/pool_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/pools_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/bdp_logo.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _showJoinDialog() async {
    _codeCtrl.clear();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.green,
        title: Text(
          'ENTRAR COM CÓDIGO',
          style: AppTextStyles.sectionTitle.copyWith(color: AppColors.amber),
        ),
        content: TextField(
          controller: _codeCtrl,
          textCapitalization: TextCapitalization.characters,
          maxLength: 8,
          style: AppTextStyles.inviteCode.copyWith(
            fontSize: 24,
            color: AppColors.offWhite,
          ),
          decoration: InputDecoration(
            hintText: 'ABCD1234',
            hintStyle: AppTextStyles.inviteCode.copyWith(
              fontSize: 24,
              color: AppColors.mutedText,
            ),
            filled: true,
            fillColor: AppColors.greenMid,
            border: const OutlineInputBorder(
              borderRadius: AppSpacing.inputRadius,
              borderSide: BorderSide.none,
            ),
            counterStyle: AppTextStyles.caption,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCELAR', style: AppTextStyles.caption),
          ),
          ElevatedButton(
            onPressed: () {
              final code = _codeCtrl.text.trim().toUpperCase();
              if (code.length == 8) {
                Navigator.pop(ctx);
                context.push('/join/$code');
              }
            },
            child: const Text('ENTRAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider).valueOrNull;
    final user = authState?.user;
    final poolsAsync = ref.watch(poolsProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        title: Row(
          children: const [
            BdpHexLogo(size: 28),
            SizedBox(width: 10),
            BdpLogotype(),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.offWhite),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.amber,
        onRefresh: () => ref.read(poolsProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
                child: Text(
                  'Olá, ${user?.name.split(' ').first ?? 'campeão'}! 👋',
                  style: AppTextStyles.screenTitle,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.pagePadding,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/pool/create'),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('CRIAR BOLÃO'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                        ),
                      ),
                    ),
                    AppSpacing.gapSmH,
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showJoinDialog,
                        icon: const Icon(Icons.group_add_outlined, size: 18),
                        label: const Text('ENTRAR'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.gapLg,
            poolsAsync.when(
              loading: () => const SliverFillRemaining(
                child: AppLoadingIndicator(),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text(e.toString())),
              ),
              data: (pools) => pools.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.emoji_events_outlined,
                                  color: AppColors.amber, size: 56),
                              AppSpacing.gapBase,
                              Text(
                                'Nenhum bolão ainda',
                                style: AppTextStyles.sectionTitle,
                              ),
                              AppSpacing.gapSm,
                              Text(
                                'Crie um bolão ou entre\ncom um código de convite.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodySm,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: AppSpacing.pagePadding,
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _PoolCard(pool: pools[i]),
                          childCount: pools.length,
                        ),
                      ),
                    ),
            ),
            AppSpacing.gapLg,
          ],
        ),
      ),
    );
  }
}

class _PoolCard extends StatelessWidget {
  final PoolModel pool;
  const _PoolCard({required this.pool});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/pool/${pool.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: AppSpacing.cardRadius,
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.greenMid,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: pool.competition?.logoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: pool.competition!.logoUrl!,
                      width: 30,
                      height: 30,
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.emoji_events_outlined, color: AppColors.amber),
                    )
                  : const Icon(Icons.emoji_events_outlined, color: AppColors.amber),
            ),
            const SizedBox(width: AppSpacing.md + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pool.name, style: AppTextStyles.cardTitle),
                  Text(
                    pool.competition?.name ?? '',
                    style: AppTextStyles.caption,
                  ),
                  AppSpacing.gapXs,
                  Row(
                    children: [
                      _Chip(
                        icon: Icons.group_outlined,
                        label: '${pool.count?.members ?? 0}',
                      ),
                      AppSpacing.gapSmH,
                      _Chip(
                        icon: Icons.sports_soccer,
                        label: '${pool.count?.poolMatches ?? 0} jogos',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.mutedText),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.mutedText),
        AppSpacing.gapXs,
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
