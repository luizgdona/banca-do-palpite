import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/pool_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/pools_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loading.dart';

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
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        title: Text(
          'ENTRAR COM CÓDIGO',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
        ),
        content: TextField(
          controller: _codeCtrl,
          textCapitalization: TextCapitalization.characters,
          maxLength: 8,
          style: AppTextStyles.inviteCode.copyWith(
            fontSize: 24,
            letterSpacing: 6,
          ),
          decoration: InputDecoration(
            hintText: 'ABCD1234',
            hintStyle: AppTextStyles.inviteCode.copyWith(
              fontSize: 24,
              letterSpacing: 6,
              color: AppColors.onSurfaceVariant,
            ),
            filled: true,
            fillColor: AppColors.background,
            counterStyle: AppTextStyles.caption,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surfaceContainerHigh,
          onRefresh: () => ref.read(poolsProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              // ── Header ────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MEU BOLÃO',
                        style: AppTextStyles.labelUppercase,
                      ),
                      AppSpacing.gapSm,
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Olá, ',
                              style: AppTextStyles.screenTitle.copyWith(
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w300,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            TextSpan(
                              text: user?.name.split(' ').first ?? 'Campeão',
                              style: AppTextStyles.screenTitle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Quick actions ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.pagePadding,
                  child: Row(
                    children: [
                      Expanded(
                        child: _GradientButton(
                          label: '+ CRIAR BOLÃO',
                          onTap: () => context.push('/pool/create'),
                        ),
                      ),
                      AppSpacing.gapMdH,
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _showJoinDialog,
                          child: const Text('ENTRAR'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacing.gapBase,

              // ── Section label ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.base, AppSpacing.lg, AppSpacing.sm),
                  child: Row(
                    children: [
                      Text('SEUS BOLÕES', style: AppTextStyles.labelUppercase),
                      AppSpacing.gapSmH,
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.outlineVariant,
                                AppColors.outlineVariant.withAlpha(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Pool list ─────────────────────────────────────────────────
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
                                Icon(
                                  Icons.sports_soccer_outlined,
                                  color: AppColors.onSurfaceVariant,
                                  size: 48,
                                ),
                                AppSpacing.gapBase,
                                Text(
                                  'Nenhum bolão ainda',
                                  style: AppTextStyles.sectionTitle.copyWith(
                                    fontSize: 24,
                                  ),
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

              AppSpacing.gapXl,
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pool Card ─────────────────────────────────────────────────────────────────

class _PoolCard extends StatelessWidget {
  final PoolModel pool;
  const _PoolCard({required this.pool});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      accentColor: AppColors.primary,
      bottomMargin: AppSpacing.sm + 2,
      onTap: () => context.push('/pool/${pool.id}'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.md, AppSpacing.base, AppSpacing.md),
        child: Row(
          children: [
            // Competition logo
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSpacing.radiusBase),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusBase),
                child: pool.competition?.logoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: pool.competition!.logoUrl!,
                        fit: BoxFit.contain,
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.emoji_events_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      )
                    : const Icon(
                        Icons.emoji_events_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
              ),
            ),
            AppSpacing.gapMdH,
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pool.name,
                    style: AppTextStyles.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pool.competition?.name ?? '',
                    style: AppTextStyles.cardSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Row(
                    children: [
                      _MetaChip(
                        icon: Icons.group_outlined,
                        label: '${pool.count?.members ?? 0}',
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _MetaChip(
                        icon: Icons.sports_soccer,
                        label: '${pool.count?.poolMatches ?? 0} jogos',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(
              Icons.chevron_right,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyles.micro),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryContainer],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusBase),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}
