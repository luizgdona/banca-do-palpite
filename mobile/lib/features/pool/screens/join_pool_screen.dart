import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/pools_provider.dart';
import '../../../core/theme/app_colors.dart';

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
      final response = await client.dio.post('/pools/join/${widget.inviteCode}/confirm');
      final poolId = response.data['poolId'] as String;
      if (!mounted) return;
      await ref.read(poolsProvider.notifier).refresh();
      if (!mounted) return;
      context.go('/pool/$poolId');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewAsync = ref.watch(poolPreviewProvider(widget.inviteCode));

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        title: const Text('ENTRAR NO BOLÃO'),
      ),
      body: previewAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.amber)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: AppColors.liveBadge, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Código de convite inválido',
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (preview) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (preview.competition?.logoUrl != null)
                      CachedNetworkImage(
                        imageUrl: preview.competition!.logoUrl!,
                        width: 40,
                        height: 40,
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.emoji_events_outlined, color: AppColors.amber),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      preview.name,
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.amber,
                      ),
                    ),
                    if (preview.competition != null)
                      Text(
                        preview.competition!.name,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppColors.mutedText,
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (preview.description != null && preview.description!.isNotEmpty)
                      Text(
                        preview.description!,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppColors.offWhite,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            color: AppColors.mutedText, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Criado por ${preview.owner?.name ?? 'alguém'}',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.group_outlined,
                            color: AppColors.mutedText, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${preview.memberCount} participante${preview.memberCount != 1 ? 's' : ''}',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (preview.status != 'open')
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.liveBadge.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.liveBadge),
                  ),
                  child: Text(
                    'Este bolão não está mais aceitando novos membros.',
                    style: GoogleFonts.dmSans(color: AppColors.liveBadge),
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
                              strokeWidth: 2, color: AppColors.green),
                        )
                      : const Text('ENTRAR NO BOLÃO'),
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
