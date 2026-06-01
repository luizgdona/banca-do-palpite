import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bdp_logo.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider).valueOrNull;
    final user = authState?.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.green,
        title: Row(
          children: [
            const BdpHexLogo(size: 32),
            const SizedBox(width: 10),
            const BdpLogotype(),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.offWhite),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, ${user?.name.split(' ').first ?? 'campeão'}! 👋',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Seus bolões aparecem aqui.',
                style: GoogleFonts.dmSans(color: AppColors.mutedDark),
              ),
              const SizedBox(height: 32),
              // Placeholder — bolões virão na Fase 2
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.emoji_events_outlined,
                        size: 48, color: AppColors.amber),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhum bolão ainda',
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.offWhite,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Crie um bolão ou entre com um código de convite.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('CRIAR BOLÃO'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.group_add_outlined),
                label: const Text('ENTRAR COM CÓDIGO'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.green,
                  side: const BorderSide(color: AppColors.green, width: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
