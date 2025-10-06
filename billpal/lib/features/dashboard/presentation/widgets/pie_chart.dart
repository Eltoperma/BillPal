import 'package:flutter/material.dart';

/// Öffentliches Datenmodell für ein Kuchendiagramm-Segment.
class PieSlice {
  final double value; // Anteil (0..1)
  final Color color;
  const PieSlice({required this.value, required this.color});
}

/// Donut-Kuchendiagramm ohne externe Packages.
/// Exponiert nur das Widget; der Painter bleibt privat in dieser Datei.
class PieChart extends StatelessWidget {
  final List<PieSlice> slices;
  const PieChart({super.key, required this.slices});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PieChartPainter(slices),
      child: const SizedBox.expand(),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<PieSlice> slices;
  _PieChartPainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    final center = (Offset.zero & size).center;
    final radius = size.shortestSide / 2;
    final strokeWidth = radius * 0.6;
    var startAngle = -90.0 * (3.1415926535 / 180.0);

    for (final s in slices) {
      final sweep = s.value * 2 * 3.1415926535;
      final paint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      final arcRect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);
      canvas.drawArc(arcRect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }

    final shadowPaint = Paint()
      ..color = Colors.black12
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, radius * 0.02, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter old) => old.slices != slices;
}
