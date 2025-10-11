import 'dart:math' as math;
import 'package:billpal/models/financial_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PieChart extends StatelessWidget {
  final List<PieSlice> slices;
  final double size;
  final bool showLegend;
  final bool showLabels;
  final double strokeWidth;

  const PieChart({
    super.key,
    required this.slices,
    this.size = 240,
    this.showLegend = true,
    this.showLabels = false,
    this.strokeWidth = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    if (slices.isEmpty) return _buildEmptyState();

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _PieChartPainter(
              slices,
              showLabels: showLabels,
              strokeWidth: strokeWidth,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        if (showLegend) ...[const SizedBox(height: 24), _buildLegend()],
      ],
    );
  }

  Widget _buildEmptyState() => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      shape: BoxShape.circle,
    ),
    child: const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'Noch keine Ausgaben',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          Text(
            'Erstelle deine erste geteilte Rechnung!',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    ),
  );

  Widget _buildLegend() => Wrap(
    spacing: 16,
    runSpacing: 8,
    children: slices.map(_buildLegendItem).toList(),
  );

  Widget _buildLegendItem(PieSlice slice) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: slice.color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 8),
      Text(
        slice.label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      const SizedBox(width: 4),
      Text(
        '(${slice.amount.toStringAsFixed(0)}€)',
        style: const TextStyle(fontSize: 12, color: Colors.black54),
      ),
    ],
  );
}

// private Painter Class
class _PieChartPainter extends CustomPainter {
  final List<PieSlice> slices;
  final bool showLabels;
  final double strokeWidth;
  final TextStyle labelStyle;

  _PieChartPainter(
    this.slices, {
    this.showLabels = false,
    this.strokeWidth = 40.0,
    TextStyle? labelStyle,
  }) : labelStyle =
           labelStyle ??
           const TextStyle(
             color: Colors.white,
             fontSize: 12,
             fontWeight: FontWeight.bold,
           );

  @override
  void paint(Canvas canvas, Size size) {
    if (slices.isEmpty) return;

    final center = (Offset.zero & size).center;
    final radius = size.shortestSide / 2;
    final ringRadius = radius - strokeWidth / 2;

    // Werte robust normalisieren (falls Summe != 1.0)
    final total = slices.fold<double>(
      0,
      (sum, s) => sum + (s.value.isFinite ? s.value : 0),
    );
    if (total <= 0) return;

    var startAngle = -math.pi / 2; // 12 Uhr
    for (final slice in slices) {
      final share = (slice.value <= 0) ? 0.0 : slice.value / total;
      final sweepAngle = share * 2 * math.pi;
      if (sweepAngle <= 0) continue;

      final paint = Paint()
        ..isAntiAlias = true
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      final arcRect = Rect.fromCircle(center: center, radius: ringRadius);
      canvas.drawArc(arcRect, startAngle, sweepAngle, false, paint);

      // Labels nur bei ausreichend großem Segment zeichnen (~11.5°)
      if (showLabels && sweepAngle > 0.2) {
        _drawLabel(canvas, center, ringRadius, startAngle, sweepAngle, slice);
      }

      startAngle += sweepAngle;
    }

    // kleiner "Glanzpunkt"/Schatten in der Mitte
    final shadowPaint = Paint()
      ..color = Colors.black12
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, radius * 0.02, shadowPaint);
  }

  void _drawLabel(
    Canvas canvas,
    Offset center,
    double ringRadius,
    double startAngle,
    double sweepAngle,
    PieSlice slice,
  ) {
    final angle = startAngle + sweepAngle / 2;
    final r = ringRadius * 0.75; // etwas innerhalb des Rings
    final pos = Offset(
      center.dx + r * math.cos(angle),
      center.dy + r * math.sin(angle),
    );

    final tp = TextPainter(
      text: TextSpan(
        text: '${(slice.value * 100).toStringAsFixed(1)}%',
        style: labelStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter old) {
    return !listEquals(old.slices, slices) ||
        old.showLabels != showLabels ||
        old.strokeWidth != strokeWidth ||
        old.labelStyle != labelStyle;
  }
}
