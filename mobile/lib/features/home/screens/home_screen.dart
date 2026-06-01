import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/pool_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/pools_provider.dart';
import '../../../core/theme/app_colors.dart';
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
          style: GoogleFonts.barlowCondensed(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.amber,
          ),
        ),
        content: TextField(
          controller: _codeCtrl,
          textCapitalization: TextCapitalization.characters,
          maxLength: 8,
          style: GoogleFonts.barlowCondensed(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.offWhite,
            letterSpacing: 6,
          ),
          decoration: InputDecoration(
            hintText: 'ABCD1234',
            hintStyle: GoogleFonts.barlowCondensed(
              fontSize: 24,
              color: AppColors.mutedText,
              letterSpacing: 6,
            ),
            filled: true,
            fillColor: AppColors.greenMid,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            counterStyle: GoogleFonts.dmSans(color: AppColors.mutedText),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCELAR',
                style: GoogleFonts.dmSans(color: AppColors.mutedText)),
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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  'Olá, ${user?.name.split(' ').first ?? 'campeão'}! 👋',
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ),
            // Ações rápidas
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    const SizedBox(width: 10),
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
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            // Bolões
            poolsAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppColors.amber)),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text(e.toString())),
              ),
              data: (pools) => pools.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.emoji_events_outlined,
                                  color: AppColors.amber, size: 56),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhum bolão ainda',
                                style: GoogleFonts.barlowCondensed(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Crie um bolão ou entre\ncom um código de convite.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(color: AppColors.mutedDark),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _PoolCard(pool: pools[i]),
                          childCount: pools.length,
                        ),
                      ),
                    ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x20000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Logo da competição
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.greenMid,
                borderRadius: BorderRadius.circular(8),
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
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pool.name,
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.offWhite,
                    ),
                  ),
                  Text(
                    pool.competition?.name ?? '',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Chip(
                        icon: Icons.group_outlined,
                        label: '${pool.count?.members ?? 0}',
                      ),
                      const SizedBox(width: 8),
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
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.mutedText),
        ),
      ],
    );
  }
}
