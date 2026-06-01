import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Semantic text style presets. Use `.copyWith(color: ...)` to override color.
class AppTextStyles {
  AppTextStyles._();

  // ── Barlow Condensed (headings, scores, badges) ─────────────────────────────

  static TextStyle screenTitle = GoogleFonts.barlowCondensed(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.darkText,
  );

  static TextStyle sectionTitle = GoogleFonts.barlowCondensed(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.darkText,
  );

  static TextStyle cardTitle = GoogleFonts.barlowCondensed(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.offWhite,
  );

  static TextStyle tabLabel = GoogleFonts.barlowCondensed(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.mutedDark,
    letterSpacing: 1,
  );

  static TextStyle teamName = GoogleFonts.barlowCondensed(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.offWhite,
  );

  static TextStyle scoreXl = GoogleFonts.barlowCondensed(
    fontSize: 64,
    fontWeight: FontWeight.w900,
    color: AppColors.amber,
  );

  static TextStyle scoreLg = GoogleFonts.barlowCondensed(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.amber,
  );

  static TextStyle scoreMd = GoogleFonts.barlowCondensed(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: AppColors.amber,
  );

  static TextStyle badgeLabel = GoogleFonts.barlowCondensed(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.offWhite,
    letterSpacing: 0.5,
  );

  static TextStyle inviteCode = GoogleFonts.barlowCondensed(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.amber,
    letterSpacing: 8,
  );

  static TextStyle rankPosition = GoogleFonts.barlowCondensed(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    color: AppColors.mutedDark,
  );

  static TextStyle rankPositionTop = GoogleFonts.barlowCondensed(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    color: AppColors.exactColor,
  );

  static TextStyle rankPoints = GoogleFonts.barlowCondensed(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: AppColors.darkText,
  );

  // ── DM Sans (body, labels, captions) ─────────────────────────────────────────

  static TextStyle bodyMd = GoogleFonts.dmSans(
    fontSize: 14,
    color: AppColors.darkText,
  );

  static TextStyle bodySm = GoogleFonts.dmSans(
    fontSize: 13,
    color: AppColors.mutedDark,
  );

  static TextStyle caption = GoogleFonts.dmSans(
    fontSize: 12,
    color: AppColors.mutedText,
  );

  static TextStyle micro = GoogleFonts.dmSans(
    fontSize: 11,
    color: AppColors.mutedText,
  );

  static TextStyle memberName = GoogleFonts.dmSans(
    fontWeight: FontWeight.w600,
    color: AppColors.darkText,
  );
}
