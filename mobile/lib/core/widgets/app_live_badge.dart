import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Pulsing "AO VIVO" badge with optional match minute.
class AppLiveBadge extends StatefulWidget {
  final int? minute;
  const AppLiveBadge({super.key, this.minute});

  @override
  State<AppLiveBadge> createState() => _AppLiveBadgeState();
}

class _AppLiveBadgeState extends State<AppLiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(_pulse);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs / 2,
        ),
        decoration: const BoxDecoration(
          color: AppColors.liveBadge,
          borderRadius: AppSpacing.badgeRadius,
        ),
        child: Text(
          '● AO VIVO${widget.minute != null ? "  ${widget.minute}\'" : ""}',
          style: AppTextStyles.badgeLabel,
        ),
      ),
    );
  }
}
