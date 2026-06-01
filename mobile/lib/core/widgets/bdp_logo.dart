import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'dart:math' as math;

class BdpHexLogo extends StatelessWidget {
  final double size;
  final Color backgroundColor;

  const BdpHexLogo({super.key, this.size = 80, this.backgroundColor = AppColors.green});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HexPainter(),
        child: Center(
          child: Text(
            'B',
            style: GoogleFonts.barlowCondensed(
              fontSize: size * 0.42,
              fontWeight: FontWeight.w900,
              color: AppColors.offWhite,
            ),
          ),
        ),
      ),
    );
  }
}

class _HexPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Outer amber border
    _drawHex(canvas, cx, cy, size.width * 0.48, const Color(0xFFDC8C14));
    // Inner amber light
    _drawHex(canvas, cx, cy, size.width * 0.40, const Color(0xFFF0AA32));
    // Green fill
    _drawHex(canvas, cx, cy, size.width * 0.33, AppColors.greenMid);
  }

  void _drawHex(Canvas canvas, double cx, double cy, double r, Color color) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = math.pi / 180 * (60 * i - 30);
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BdpLogotype extends StatelessWidget {
  final bool dark;

  const BdpLogotype({super.key, this.dark = false});

  @override
  Widget build(BuildContext context) {
    final textColor = dark ? AppColors.darkText : AppColors.offWhite;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'BANCA DO',
          style: GoogleFonts.barlowCondensed(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: textColor,
            height: 1,
            letterSpacing: 1,
          ),
        ),
        Text(
          'PALPITE',
          style: GoogleFonts.barlowCondensed(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.amber,
            height: 1,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
