import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bdp_logo.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              // Logo
              Row(
                children: [
                  const BdpHexLogo(size: 72),
                  const SizedBox(width: 16),
                  const BdpLogotype(),
                ],
              ),
              const SizedBox(height: 24),
              // Tagline
              Text(
                'Bolão de amigos.\nPlacar em tempo real.',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  color: AppColors.mutedText,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),
              // Buttons
              ElevatedButton(
                onPressed: () => context.push('/register'),
                child: const Text('CRIAR CONTA'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push('/login'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.offWhite,
                  side: const BorderSide(color: AppColors.offWhite, width: 1.5),
                ),
                child: const Text('JÁ TENHO CONTA'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
