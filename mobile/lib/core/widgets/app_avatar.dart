import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Circular avatar showing the first letter of [name].
class AppAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final Color backgroundColor;
  final Color textColor;

  const AppAvatar({
    super.key,
    required this.name,
    this.radius = 18,
    this.backgroundColor = AppColors.green,
    this.textColor = AppColors.amber,
  });

  @override
  Widget build(BuildContext context) {
    // Use a slightly smaller font ratio so the letter sits comfortably
    final fontSize = (radius * 0.95).clamp(10.0, 36.0);
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: GoogleFonts.barlowCondensed(
          fontWeight: FontWeight.w900,
          fontSize: fontSize,
          color: textColor,
          height: 1,
        ),
      ),
    );
  }
}
