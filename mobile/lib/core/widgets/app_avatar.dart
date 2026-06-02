import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Circular avatar showing initial letter. Dark theme version.
class AppAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final Color backgroundColor;
  final Color textColor;

  const AppAvatar({
    super.key,
    required this.name,
    this.radius = 18,
    this.backgroundColor = AppColors.surfaceContainerHighest,
    this.textColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = (radius * 0.9).clamp(10.0, 36.0);
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: GoogleFonts.lexend(
          fontWeight: FontWeight.w800,
          fontSize: fontSize,
          color: textColor,
          height: 1,
        ),
      ),
    );
  }
}
