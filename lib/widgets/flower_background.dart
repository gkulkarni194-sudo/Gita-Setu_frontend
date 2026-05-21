import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FlowerBackground extends StatelessWidget {
  final Widget child;

  const FlowerBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background color
        Container(color: AppColors.background),

        // Top left flower
        Positioned(
          top: -20,
          left: -20,
          child: _buildFlowerCorner(180),
        ),

        // Top right flower
        Positioned(
          top: -20,
          right: -20,
          child: _buildFlowerCorner(180, flip: true),
        ),

        // Bottom left flower
        Positioned(
          bottom: -20,
          left: -20,
          child: _buildFlowerCorner(180, flipV: true),
        ),

        // Bottom right flower
        Positioned(
          bottom: -20,
          right: -20,
          child: _buildFlowerCorner(180, flip: true, flipV: true),
        ),

        // Content
        child,
      ],
    );
  }

  Widget _buildFlowerCorner(double size,
      {bool flip = false, bool flipV = false}) {
    return Transform(
      transform: Matrix4.diagonal3Values(
        flip ? -1.0 : 1.0,
        flipV ? -1.0 : 1.0,
        1.0,
      ),
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size(size, size),
        painter: FlowerPainter(),
      ),
    );
  }
}

class FlowerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF5C518).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw simple botanical lines
    final path1 = Path();
    path1.moveTo(0, size.height * 0.8);
    path1.cubicTo(
      size.width * 0.3,
      size.height * 0.6,
      size.width * 0.6,
      size.height * 0.3,
      size.width * 0.8,
      0,
    );
    canvas.drawPath(path1, paint);

    // Petal shapes
    for (int i = 0; i < 3; i++) {
      final cx = size.width * (0.2 + i * 0.25);
      final cy = size.height * (0.6 - i * 0.2);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: 30,
          height: 20,
        ),
        paint,
      );
    }

    // Small dots
    final dotPaint = Paint()
      ..color = const Color(0xFFF5C518).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.4), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.2), 2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
