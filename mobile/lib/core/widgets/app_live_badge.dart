import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
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
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _opacity = CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)
        .drive(Tween<double>(begin: 0.5, end: 1.0));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.minute != null
        ? '● VIVO  ${widget.minute}\''
        : '● AO VIVO';

    return FadeTransition(
      opacity: _opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.liveBadge,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: AppTextStyles.liveBadgeLabel),
      ),
    );
  }
}
