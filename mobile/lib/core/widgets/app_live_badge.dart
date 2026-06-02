import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Pulsing "AO VIVO" badge — matches the Stitch live indicator style.
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
          color: AppColors.error.withAlpha(30),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.error.withAlpha(80), width: 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.error,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}
