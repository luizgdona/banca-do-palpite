import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/pools_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_loading.dart';

class JoinPoolScreen extends ConsumerStatefulWidget {
  final String inviteCode;
  const JoinPoolScreen({super.key, required this.inviteCode});

  @override
  ConsumerState<JoinPoolScreen> createState() => _JoinPoolScreenState();
}

class _JoinPoolScreenState extends ConsumerState<JoinPoolScreen> {
  bool _isJoining = false;

  Future<void> _join() async {
    setState(() => _isJoining = true);
    try {
      final client = ref.read(apiClientProvider);
      final response =
          await client.dio.post('/pools/join/${widget.inviteCode}/confirm');
      final poolId = response.data['poolId'] as String;
      if (!mounted) return;
      await ref.read(poolsProvider.notifier).refresh();
      if (!mounted) return;
      context.go('/pool/$poolId');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewAsync = ref.watch(poolPreviewProvider(widget.inviteCode));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLow,
        title: const Text('ENTRAR NO BOLÃO'),
      ),
      body: previewAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => Center(
          child: Padding(
            padding: AppSpacing.sheetPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.error, size: 48),
                AppSpacing.gapBase,
                Text(
                  'Código de convite inválido',
                  style: AppTextStyles.sectionTitle,
                ),
              ],
            ),
          ),
        ),
        data: (preview) => Padding(
          padding: AppSpacing.sheetPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.gapBase,
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: AppSpacing.cardRadius,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (preview.competition?.logoUrl != null)
                      CachedNetworkImage(
                        imageUrl: preview.competition!.logoUrl!,
                        width: 40,
                        height: 40,
                        errorWidget: (_, __, ___) => const Icon(
                            Icons.emoji_events_outlined,
                            color: AppColors.secondary),
                      ),
                    AppSpacing.gapMd,
                    Text(
                      preview.name,
                      style: AppTextStyles.screenTitle.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    if (preview.competition != null)
                      Text(
                        preview.competition!.name,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    AppSpacing.gapBase,
                    if (preview.description != null &&
                        preview.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.base),
                        child: Text(
                          preview.description!,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    _InfoRow(
                      icon: Icons.person_outline,
                      label:
                          'Criado por ${preview.owner?.name ?? 'alguém'}',
                    ),
                    AppSpacing.gapXs,
                    _InfoRow(
                      icon: Icons.group_outlined,
                      label:
                          '${preview.memberCount} participante${preview.memberCount != 1 ? 's' : ''}',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (preview.status != 'open')
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(30),
                    borderRadius: AppSpacing.inputRadius,
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Text(
                    'Este bolão não está mais aceitando novos membros.',
                    style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.error),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: _isJoining ? null : _join,
                  child: _isJoining
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary),
                        )
                      : const Text('ENTRAR NO BOLÃO'),
                ),
              AppSpacing.gapMd,
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.onSurfaceVariant, size: 16),
        AppSpacing.gapXs,
        const SizedBox(width: 2),
        Text(label, style: AppTextStyles.bodySm),
      ],
    );
  }
}
