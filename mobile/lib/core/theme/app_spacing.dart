import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  // Base values
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;

  // Border radii
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusBase = 10;
  static const double radiusLg = 12;
  static const double radiusCard = 14;
  static const double radiusXl = 20;

  // Common border radius objects
  static const cardRadius = BorderRadius.all(Radius.circular(radiusCard));
  static const inputRadius = BorderRadius.all(Radius.circular(radiusBase));
  static const badgeRadius = BorderRadius.all(Radius.circular(radiusSm));
  static const chipRadius = BorderRadius.all(Radius.circular(radiusXl));

  // Vertical SizedBox gaps
  static const gapXs = SizedBox(height: xs);
  static const gapSm = SizedBox(height: sm);
  static const gapMd = SizedBox(height: md);
  static const gapBase = SizedBox(height: base);
  static const gapLg = SizedBox(height: lg);
  static const gapXl = SizedBox(height: xl);
  static const gapXxl = SizedBox(height: xxl);

  // Horizontal SizedBox gaps
  static const gapSmH = SizedBox(width: sm);
  static const gapMdH = SizedBox(width: md);
  static const gapBaseH = SizedBox(width: base);

  // Common EdgeInsets
  static const pagePadding = EdgeInsets.symmetric(horizontal: lg);
  static const pageVertical = EdgeInsets.all(base);
  static const cardPadding = EdgeInsets.all(base);
  static const sheetPadding = EdgeInsets.all(xl);
}
