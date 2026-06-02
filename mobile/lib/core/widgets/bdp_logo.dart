import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'dart:math' as math;

/// Hexagonal logo mark. Pass [size] for the bounding box dimension.
class BdpHexLogo extends StatelessWidget {
  final double size;

  const BdpHexLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HexLogoPainter(),
        child: Center(
          child: Text(
            'B',
            style: GoogleFonts.barlowCondensed(
              fontSize: size * 0.46,
              fontWeight: FontWeight.w900,
              color: AppColors.green,
              height: 1,
              letterSpacing: -1,
            ),
          ),
        ),
      ),
    );
  }
}

class _HexLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // ── Drop shadow ─────────────────────────────────────────────────────────
    final shadowPaint = Paint()
      ..color = const Color(0x40000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    _drawHexPath(canvas, cx, cy + 2, size.width * 0.47, shadowPaint);

    // ── Thin dark outer ring (gives weight) ─────────────────────────────────
    final outerRingPaint = Paint()..color = AppColors.amberDark;
    _drawHexPath(canvas, cx, cy, size.width * 0.49, outerRingPaint);

    // ── Amber gradient fill ─────────────────────────────────────────────────
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.amberLight, AppColors.amberDark],
      ).createShader(Rect.fromCenter(
        center: Offset(cx, cy),
        width: size.width,
        height: size.height,
      ));
    _drawHexPath(canvas, cx, cy, size.width * 0.44, gradientPaint);

    // ── Subtle top-left shine ────────────────────────────────────────────────
    final shinePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.5, -0.6),
        radius: 0.65,
        colors: [
          Colors.white.withAlpha(40),
          Colors.white.withAlpha(0),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(cx, cy),
        width: size.width,
        height: size.height,
      ));
    _drawHexPath(canvas, cx, cy, size.width * 0.44, shinePaint);

    // ── Thin inner ring (gives depth between amber and letter) ───────────────
    final innerRingPaint = Paint()
      ..color = AppColors.amberDark.withAlpha(180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.025;
    _drawHexPath(canvas, cx, cy, size.width * 0.36, innerRingPaint);
  }

  Path _hexPath(double cx, double cy, double r) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = math.pi / 180 * (60 * i - 30);
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  void _drawHexPath(Canvas canvas, double cx, double cy, double r, Paint paint) {
    canvas.drawPath(_hexPath(cx, cy, r), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Full logotype: hex mark + "BANCA DO / PALPITE" wordmark.
class BdpLogotype extends StatelessWidget {
  final bool dark;

  const BdpLogotype({super.key, this.dark = false});

  @override
  Widget build(BuildContext context) {
    final labelColor = dark ? AppColors.darkText.withAlpha(160) : AppColors.offWhite.withAlpha(180);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'BANCA DO',
          style: GoogleFonts.barlowCondensed(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: labelColor,
            height: 1,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          'PALPITE',
          style: GoogleFonts.barlowCondensed(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.amber,
            height: 1,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
