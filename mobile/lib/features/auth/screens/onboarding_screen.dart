import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/bdp_logo.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 28, vertical: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              Row(
                children: const [
                  BdpHexLogo(size: 72),
                  SizedBox(width: AppSpacing.base),
                  BdpLogotype(),
                ],
              ),
              AppSpacing.gapXl,
              Text(
                'Bolão de amigos.\nPlacar em tempo real.',
                style: AppTextStyles.bodyMd.copyWith(
                  fontSize: 18,
                  color: AppColors.mutedText,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),
              ElevatedButton(
                onPressed: () => context.push('/register'),
                child: const Text('CRIAR CONTA'),
              ),
              AppSpacing.gapMd,
              OutlinedButton(
                onPressed: () => context.push('/login'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.offWhite,
                  side: const BorderSide(color: AppColors.offWhite, width: 1.5),
                ),
                child: const Text('JÁ TENHO CONTA'),
              ),
              AppSpacing.gapXl,
            ],
          ),
        ),
      ),
    );
  }
}
