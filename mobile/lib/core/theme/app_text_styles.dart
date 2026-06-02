import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Semantic text style presets matching the Stitch design system.
/// Headline: Lexend | Body: Work Sans | Label: Space Grotesk
class AppTextStyles {
  AppTextStyles._();

  // ── Lexend — headings, scores, brand ─────────────────────────────────────────

  static TextStyle heroTitle = GoogleFonts.lexend(
    fontSize: 72,
    fontWeight: FontWeight.w900,
    color: AppColors.onBackground,
    letterSpacing: -2,
    height: 0.95,
  );

  static TextStyle screenTitle = GoogleFonts.lexend(
    fontSize: 40,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
    color: AppColors.onBackground,
    letterSpacing: -1,
    height: 1,
  );

  static TextStyle sectionTitle = GoogleFonts.lexend(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
    color: AppColors.onBackground,
    letterSpacing: -0.5,
    height: 1,
  );

  static TextStyle cardTitle = GoogleFonts.lexend(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    height: 1.2,
  );

  static TextStyle cardSubtitle = GoogleFonts.spaceGrotesk(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
    height: 1.3,
  );

  static TextStyle teamName = GoogleFonts.lexend(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    letterSpacing: 0.2,
    height: 1.1,
  );

  static TextStyle scoreXl = GoogleFonts.lexend(
    fontSize: 80,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
    height: 1,
    letterSpacing: -2,
  );

  static TextStyle scoreLg = GoogleFonts.lexend(
    fontSize: 40,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
    height: 1,
    letterSpacing: -1,
  );

  static TextStyle scoreMd = GoogleFonts.lexend(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
    height: 1,
    letterSpacing: -0.5,
  );

  static TextStyle inputScore = GoogleFonts.lexend(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
    height: 1,
  );

  static TextStyle rankPoints = GoogleFonts.lexend(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    height: 1,
  );

  static TextStyle rankPosition = GoogleFonts.lexend(
    fontSize: 18,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
    color: AppColors.onSurfaceVariant,
    height: 1,
  );

  static TextStyle rankPositionTop = GoogleFonts.lexend(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
    color: AppColors.secondary,
    height: 1,
  );

  static TextStyle inviteCode = GoogleFonts.lexend(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
    letterSpacing: 10,
    height: 1,
  );

  static TextStyle badgeLabel = GoogleFonts.spaceGrotesk(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    letterSpacing: 0.8,
    height: 1,
  );

  static TextStyle liveBadgeLabel = GoogleFonts.spaceGrotesk(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    letterSpacing: 0.8,
    height: 1,
  );

  // ── Work Sans — body ──────────────────────────────────────────────────────────

  static TextStyle bodyLg = GoogleFonts.workSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
    height: 1.5,
  );

  static TextStyle bodyMd = GoogleFonts.workSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
    height: 1.4,
  );

  static TextStyle bodyMdSemiBold = GoogleFonts.workSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.4,
  );

  static TextStyle bodySm = GoogleFonts.workSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
    height: 1.4,
  );

  static TextStyle memberName = GoogleFonts.workSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.3,
  );

  // ── Space Grotesk — labels, tags, metadata ────────────────────────────────────

  static TextStyle tabLabel = GoogleFonts.spaceGrotesk(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurfaceVariant,
    letterSpacing: 1.5,
    height: 1,
  );

  static TextStyle caption = GoogleFonts.spaceGrotesk(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
    height: 1.3,
  );

  static TextStyle micro = GoogleFonts.spaceGrotesk(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static TextStyle labelUppercase = GoogleFonts.spaceGrotesk(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: 2,
    height: 1,
  );
}
