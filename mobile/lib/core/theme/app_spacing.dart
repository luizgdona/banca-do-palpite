import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  // ── Base scale ───────────────────────────────────────────────────────────────
  static const double xs   =  4;
  static const double sm   =  8;
  static const double md   = 12;
  static const double base = 16;
  static const double lg   = 20;
  static const double xl   = 24;
  static const double xxl  = 32;

  // ── Border radii ─────────────────────────────────────────────────────────────
  static const double radiusSm   =  4;
  static const double radiusMd   =  8;
  static const double radiusBase = 10;
  static const double radiusLg   = 12;
  static const double radiusCard = 16;   // bumped: rounder, more modern
  static const double radiusXl   = 24;

  // Border radius objects
  static const cardRadius  = BorderRadius.all(Radius.circular(radiusCard));
  static const inputRadius = BorderRadius.all(Radius.circular(radiusBase));
  static const badgeRadius = BorderRadius.all(Radius.circular(radiusSm));
  static const chipRadius  = BorderRadius.all(Radius.circular(radiusXl));
  static const lgRadius    = BorderRadius.all(Radius.circular(radiusLg));

  // ── Gaps (vertical) ──────────────────────────────────────────────────────────
  static const gapXs  = SizedBox(height: xs);
  static const gapSm  = SizedBox(height: sm);
  static const gapMd  = SizedBox(height: md);
  static const gapBase= SizedBox(height: base);
  static const gapLg  = SizedBox(height: lg);
  static const gapXl  = SizedBox(height: xl);
  static const gapXxl = SizedBox(height: xxl);

  // ── Gaps (horizontal) ────────────────────────────────────────────────────────
  static const gapSmH  = SizedBox(width: sm);
  static const gapMdH  = SizedBox(width: md);
  static const gapBaseH= SizedBox(width: base);

  // ── Common EdgeInsets ────────────────────────────────────────────────────────
  static const pagePadding  = EdgeInsets.symmetric(horizontal: lg);
  static const pageVertical = EdgeInsets.all(base);
  static const cardPadding  = EdgeInsets.symmetric(horizontal: base, vertical: md + 2);
  static const sheetPadding = EdgeInsets.all(xl);
  static const listPadding  = EdgeInsets.symmetric(horizontal: base, vertical: base);

  // ── Standard card shadow ─────────────────────────────────────────────────────
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x28000000),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> subtleShadow = [
    BoxShadow(
      color: Color(0x18000000),
      blurRadius: 8,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];
}
