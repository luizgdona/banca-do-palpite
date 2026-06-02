import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Standard green card used throughout the app.
/// Handles gradient, shadow, border, and tap ripple consistently.
class AppCard extends StatelessWidget {
  final Widget child;

  /// Optional colored border (e.g. live-red for live matches).
  final Color? borderColor;
  final double borderWidth;

  /// Bottom spacing between consecutive cards.
  final double bottomMargin;

  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.borderColor,
    this.borderWidth = 1.5,
    this.bottomMargin = AppSpacing.sm + 2,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.green, AppColors.greenDark],
          stops: [0.2, 1.0],
        ),
        borderRadius: AppSpacing.cardRadius,
        // Outer border — reserve space even when absent so layout is stable.
        border: Border.all(
          color: borderColor ?? Colors.transparent,
          width: borderWidth,
        ),
        boxShadow: AppSpacing.subtleShadow,
      ),
      child: ClipRRect(
        borderRadius: AppSpacing.cardRadius,
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                splashColor: AppColors.greenLight.withAlpha(40),
                highlightColor: AppColors.greenLight.withAlpha(20),
                child: child,
              )
            : child,
      ),
    );
  }
}
