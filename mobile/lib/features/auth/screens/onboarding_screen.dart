import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/bdp_logo.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 28, vertical: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              // Logo
              const BdpLogotype(fontSize: 32),
              AppSpacing.gapXl,
              // Hero text
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Bolão de amigos.\n',
                      style: AppTextStyles.heroTitle.copyWith(
                        color: AppColors.onBackground,
                      ),
                    ),
                    TextSpan(
                      text: 'Placar em\ntempo real.',
                      style: AppTextStyles.heroTitle.copyWith(
                        color: AppColors.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              // Buttons
              _GradientButton(
                label: 'CRIAR CONTA',
                onTap: () => context.push('/register'),
              ),
              AppSpacing.gapMd,
              OutlinedButton(
                onPressed: () => context.push('/login'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.outlineVariant),
                ),
                child: Text(
                  'JÁ TENHO CONTA',
                  style: GoogleFonts.workSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
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

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
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
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}
