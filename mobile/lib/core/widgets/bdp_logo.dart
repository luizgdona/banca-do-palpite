import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Primary logotype — italic bold Lexend in neon green.
/// Follows the same pattern as the "Chuteira Preta" reference design.
class BdpLogotype extends StatelessWidget {
  final double fontSize;
  final Color? color;

  const BdpLogotype({super.key, this.fontSize = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Banca do Palpite',
      style: GoogleFonts.lexend(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        color: color ?? AppColors.primary,
        letterSpacing: -0.5,
        height: 1,
      ),
    );
  }
}

/// Compact one-line logo for tight spaces (e.g. app bar).
class BdpLogoCompact extends StatelessWidget {
  final double fontSize;

  const BdpLogoCompact({super.key, this.fontSize = 22});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Banca do ',
            style: GoogleFonts.lexend(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: AppColors.onSurface,
              letterSpacing: -0.3,
              height: 1,
            ),
          ),
          TextSpan(
            text: 'Palpite',
            style: GoogleFonts.lexend(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: AppColors.primary,
              letterSpacing: -0.3,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Legacy hex logo — now renders as a styled mark for backward compat.
class BdpHexLogo extends StatelessWidget {
  final double size;

  const BdpHexLogo({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.18),
      ),
      child: Center(
        child: Text(
          'B',
          style: GoogleFonts.lexend(
            fontSize: size * 0.58,
            fontWeight: FontWeight.w900,
            color: AppColors.onPrimary,
            height: 1,
          ),
        ),
      ),
    );
  }
}
