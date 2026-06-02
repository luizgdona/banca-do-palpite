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

  // ── Border radii — matches Stitch design (very subtle, sharp aesthetic) ──────
  static const double radiusSm   =  2;   // DEFAULT in Stitch
  static const double radiusMd   =  4;   // lg
  static const double radiusBase =  8;   // xl
  static const double radiusLg   = 10;
  static const double radiusCard = 12;   // full (pill badges)
  static const double radiusXl   = 16;

  static const cardRadius   = BorderRadius.all(Radius.circular(radiusCard));
  static const inputRadius  = BorderRadius.all(Radius.circular(radiusBase));
  static const badgeRadius  = BorderRadius.all(Radius.circular(radiusCard));
  static const chipRadius   = BorderRadius.all(Radius.circular(radiusCard));
  static const lgRadius     = BorderRadius.all(Radius.circular(radiusLg));
  static const tileRadius   = BorderRadius.all(Radius.circular(radiusBase));

  // ── Gaps (vertical) ──────────────────────────────────────────────────────────
  static const gapXs   = SizedBox(height: xs);
  static const gapSm   = SizedBox(height: sm);
  static const gapMd   = SizedBox(height: md);
  static const gapBase = SizedBox(height: base);
  static const gapLg   = SizedBox(height: lg);
  static const gapXl   = SizedBox(height: xl);
  static const gapXxl  = SizedBox(height: xxl);

  // ── Gaps (horizontal) ────────────────────────────────────────────────────────
  static const gapSmH   = SizedBox(width: sm);
  static const gapMdH   = SizedBox(width: md);
  static const gapBaseH = SizedBox(width: base);

  // ── Common EdgeInsets ────────────────────────────────────────────────────────
  static const pagePadding  = EdgeInsets.symmetric(horizontal: lg);
  static const pageVertical = EdgeInsets.all(base);
  static const cardPadding  = EdgeInsets.symmetric(horizontal: base, vertical: md + 2);
  static const sheetPadding = EdgeInsets.all(xl);
  static const listPadding  = EdgeInsets.symmetric(horizontal: base, vertical: base);

  // ── Card shadow ──────────────────────────────────────────────────────────────
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x30000000), blurRadius: 20, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x10000000), blurRadius: 4, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> subtleShadow = [
    BoxShadow(color: Color(0x20000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  // ── Sidebar ──────────────────────────────────────────────────────────────────
  static const double sidebarWidth = 256;
}
