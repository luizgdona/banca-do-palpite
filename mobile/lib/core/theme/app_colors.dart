import 'package:flutter/material.dart';

/// Banca do Palpite — design system colors.
/// Dark-first palette matching the Stitch design reference.
class AppColors {
  AppColors._();

  // ── Background / Surface layers (darkest → brightest) ───────────────────────
  static const background            = Color(0xFF0E0E0E);
  static const surfaceContainerLow   = Color(0xFF131313);
  static const surfaceContainer      = Color(0xFF1A1A1A);
  static const surfaceContainerHigh  = Color(0xFF20201F);
  static const surfaceContainerHighest = Color(0xFF262626);
  static const surfaceBright         = Color(0xFF2C2C2C);

  // ── Primary — neon lime green ────────────────────────────────────────────────
  static const primary          = Color(0xFF9DF197);
  static const primaryContainer = Color(0xFF62B260);
  static const primaryDim       = Color(0xFF90E28A);
  static const onPrimary        = Color(0xFF005C15);
  static const onPrimaryContainer = Color(0xFF002A05);

  // ── Secondary — golden yellow ────────────────────────────────────────────────
  static const secondary          = Color(0xFFF5CE53);
  static const secondaryContainer = Color(0xFF735C00);
  static const secondaryDim       = Color(0xFFE6C047);
  static const onSecondary        = Color(0xFF584500);
  static const onSecondaryContainer = Color(0xFFFFF7EA);

  // ── Text / On-colors ─────────────────────────────────────────────────────────
  static const onBackground    = Color(0xFFFFFFFF);
  static const onSurface       = Color(0xFFFFFFFF);
  static const onSurfaceVariant = Color(0xFFADAAAA);
  static const outline         = Color(0xFF767575);
  static const outlineVariant  = Color(0xFF484847);

  // ── Status ───────────────────────────────────────────────────────────────────
  static const error           = Color(0xFFFF716C);
  static const errorContainer  = Color(0xFF9F0519);
  static const onError         = Color(0xFF490006);

  // ── Medals ───────────────────────────────────────────────────────────────────
  static const goldMedal   = Color(0xFFF5CE53); // reuses secondary
  static const silverMedal = Color(0xFFB0B0B0);
  static const bronzeMedal = Color(0xFFCD7F32);

  // ── Semantic aliases for existing code ───────────────────────────────────────
  /// Kept for compatibility — maps to primary in the new dark palette.
  static const green        = Color(0xFF1C6D24);
  static const greenDark    = Color(0xFF0E3D1A);
  static const greenMid     = Color(0xFF1E6444);
  static const greenLight   = Color(0xFF2D8255);
  static const amber        = Color(0xFFF5CE53);
  static const amberLight   = Color(0xFFF5CE53);
  static const amberDark    = Color(0xFFE6C047);
  static const cream        = Color(0xFF0E0E0E);   // was bg, now dark
  static const offWhite     = Color(0xFFFFFFFF);
  static const darkText     = Color(0xFFFFFFFF);
  static const mutedText    = Color(0xFFADAAAA);
  static const mutedDark    = Color(0xFFADAAAA);
  static const inputFill    = Color(0xFF000000);
  static const divider      = Color(0xFF484847);
  static const liveBadge    = Color(0xFFFF716C);
  static const winColor     = Color(0xFF9DF197);
  static const exactColor   = Color(0xFFF5CE53);
  static const lossColor    = Color(0xFF484847);

  // ── Shadows ───────────────────────────────────────────────────────────────────
  static const cardShadow  = Color(0x40000000);
  static const shadowDark  = Color(0x60000000);
}
