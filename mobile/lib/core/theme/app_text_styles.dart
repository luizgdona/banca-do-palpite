import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Semantic text style presets. Use `.copyWith(color: ...)` to override.
class AppTextStyles {
  AppTextStyles._();

  // ── Barlow Condensed — headings, scores, badges ──────────────────────────────

  static TextStyle screenTitle = GoogleFonts.barlowCondensed(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.darkText,
    letterSpacing: -0.3,
    height: 1.1,
  );

  static TextStyle sectionTitle = GoogleFonts.barlowCondensed(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.darkText,
    letterSpacing: -0.2,
    height: 1.1,
  );

  static TextStyle cardTitle = GoogleFonts.barlowCondensed(
    fontSize: 19,
    fontWeight: FontWeight.w800,
    color: AppColors.offWhite,
    letterSpacing: 0.1,
    height: 1.2,
  );

  static TextStyle cardSubtitle = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedText,
    height: 1.3,
  );

  static TextStyle tabLabel = GoogleFonts.barlowCondensed(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.mutedDark,
    letterSpacing: 0.8,
    height: 1,
  );

  static TextStyle teamName = GoogleFonts.barlowCondensed(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.offWhite,
    letterSpacing: 0.1,
    height: 1.2,
  );

  static TextStyle scoreXl = GoogleFonts.barlowCondensed(
    fontSize: 64,
    fontWeight: FontWeight.w900,
    color: AppColors.amber,
    height: 1,
    letterSpacing: -1,
  );

  static TextStyle scoreLg = GoogleFonts.barlowCondensed(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.amber,
    height: 1,
    letterSpacing: -0.5,
  );

  static TextStyle scoreMd = GoogleFonts.barlowCondensed(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    color: AppColors.amber,
    height: 1,
    letterSpacing: -0.3,
  );

  static TextStyle badgeLabel = GoogleFonts.barlowCondensed(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.offWhite,
    letterSpacing: 0.6,
    height: 1,
  );

  static TextStyle liveBadgeLabel = GoogleFonts.barlowCondensed(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    color: AppColors.offWhite,
    letterSpacing: 0.8,
    height: 1,
  );

  static TextStyle inviteCode = GoogleFonts.barlowCondensed(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.amber,
    letterSpacing: 10,
    height: 1,
  );

  static TextStyle rankPosition = GoogleFonts.barlowCondensed(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    color: AppColors.mutedDark,
    height: 1,
  );

  static TextStyle rankPositionTop = GoogleFonts.barlowCondensed(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    color: AppColors.exactColor,
    height: 1,
  );

  static TextStyle rankPoints = GoogleFonts.barlowCondensed(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    color: AppColors.darkText,
    height: 1,
    letterSpacing: -0.3,
  );

  // ── DM Sans — body, labels, captions ─────────────────────────────────────────

  static TextStyle bodyMd = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.darkText,
    height: 1.4,
  );

  static TextStyle bodyMdSemiBold = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.darkText,
    height: 1.4,
  );

  static TextStyle bodySm = GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedDark,
    height: 1.4,
  );

  static TextStyle caption = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedText,
    height: 1.3,
  );

  static TextStyle micro = GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedText,
    height: 1.2,
  );

  static TextStyle memberName = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.darkText,
    height: 1.3,
  );
}
