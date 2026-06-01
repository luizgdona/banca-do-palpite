import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Centered amber loading indicator, consistent across all screens.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.amber),
    );
  }
}

/// Full-screen scaffold with a centered loading indicator.
class AppLoadingScaffold extends StatelessWidget {
  const AppLoadingScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.cream,
      body: AppLoadingIndicator(),
    );
  }
}
