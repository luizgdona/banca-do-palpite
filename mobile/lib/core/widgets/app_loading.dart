import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Centered neon-green loading indicator.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 2,
      ),
    );
  }
}

/// Full-screen dark scaffold with loading indicator.
class AppLoadingScaffold extends StatelessWidget {
  const AppLoadingScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: AppLoadingIndicator(),
    );
  }
}
