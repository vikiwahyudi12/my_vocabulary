import 'dart:math' as math;
import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showShadow;

  const AppLogo({
    super.key,
    this.size = 40,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: const Color(0xFF0E7A53).withValues(alpha: 0.28),
                  blurRadius: size * 0.28,
                  offset: Offset(0, size * 0.1),
                ),
                BoxShadow(
                  color: const Color(0xFF044E36).withValues(alpha: 0.15),
                  blurRadius: size * 0.08,
                  offset: Offset(0, size * 0.02),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.28),
        child: CustomPaint(
          size: Size(size, size),
          painter: _ModernAppLogoPainter(),
        ),
      ),
    );
  }
}

class _ModernAppLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Rich Multi-stop Background Gradient (Deep Pine to Vibrant Emerald)
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF10B981), // Fresh emerald
          Color(0xFF059669), // Rich green
          Color(0xFF044E36), // Deep pine
        ],
        stops: [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // 2. Subtle Upper Gloss/Highlight Arc
    final glossPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.22),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.5));

    final glossPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.4)
      ..quadraticBezierTo(w * 0.5, h * 0.52, 0, h * 0.4)
      ..close();
    canvas.drawPath(glossPath, glossPaint);

    // 3. Central Modern Geometric Open Book / "V" Sprout Monogram
    final cx = w * 0.5;
    final cy = h * 0.52;

    // Left Page (Curved aerodynamic wing)
    final leftPath = Path()
      ..moveTo(cx - w * 0.03, cy + h * 0.22)
      ..lineTo(cx - w * 0.03, cy - h * 0.12)
      ..cubicTo(
        cx - w * 0.18,
        cy - h * 0.22,
        cx - w * 0.32,
        cy - h * 0.16,
        cx - w * 0.33,
        cy - h * 0.06,
      )
      ..lineTo(cx - w * 0.33, cy + h * 0.14)
      ..cubicTo(
        cx - w * 0.25,
        cy + h * 0.08,
        cx - w * 0.14,
        cy + h * 0.14,
        cx - w * 0.03,
        cy + h * 0.22,
      )
      ..close();

    final leftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.95),
          const Color(0xFFD1FAE5),
        ],
      ).createShader(Rect.fromLTWH(cx - w * 0.35, cy - h * 0.25, w * 0.35, h * 0.5));
    canvas.drawPath(leftPath, leftPaint);

    // Right Page (Elevated luminous wing)
    final rightPath = Path()
      ..moveTo(cx + w * 0.03, cy + h * 0.22)
      ..lineTo(cx + w * 0.03, cy - h * 0.12)
      ..cubicTo(
        cx + w * 0.18,
        cy - h * 0.22,
        cx + w * 0.32,
        cy - h * 0.16,
        cx + w * 0.33,
        cy - h * 0.06,
      )
      ..lineTo(cx + w * 0.33, cy + h * 0.14)
      ..cubicTo(
        cx + w * 0.25,
        cy + h * 0.08,
        cx + w * 0.14,
        cy + h * 0.14,
        cx + w * 0.03,
        cy + h * 0.22,
      )
      ..close();

    final rightPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          Color(0xFFA7F3D0),
        ],
      ).createShader(Rect.fromLTWH(cx, cy - h * 0.25, w * 0.35, h * 0.5));
    canvas.drawPath(rightPath, rightPaint);

    // 4. Center Spine (Stylized Glowing Bookmark Ribbon)
    final spinePath = Path()
      ..moveTo(cx, cy - h * 0.15)
      ..lineTo(cx + w * 0.045, cy + h * 0.24)
      ..lineTo(cx, cy + h * 0.20)
      ..lineTo(cx - w * 0.045, cy + h * 0.24)
      ..close();

    final spinePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF34D399),
          Color(0xFF047857),
        ],
      ).createShader(Rect.fromLTWH(cx - w * 0.05, cy - h * 0.15, w * 0.1, h * 0.4));
    canvas.drawPath(spinePath, spinePaint);

    // 5. Modern 4-point Spark / Star (Top Right Corner)
    final sparkPaint = Paint()
      ..color = const Color(0xFFFDE047) // Warm gold star
      ..style = PaintingStyle.fill;

    _drawStar(canvas, cx + w * 0.23, cy - h * 0.20, w * 0.06, sparkPaint);
  }

  void _drawStar(Canvas canvas, double x, double y, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final radius = i.isEven ? r : r * 0.35;
      final angle = (i * math.pi) / 4;
      final px = x + radius * math.cos(angle);
      final py = y + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
