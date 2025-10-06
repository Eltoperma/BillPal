import 'dart:math' as dart_math;
import 'package:flutter/material.dart';
import '../models/financial_data.dart';

/// CustomPainter für das Ausgaben-Kreisdiagramm
class ExpensePieChartPainter extends CustomPainter {
  final List<ExpensePieSlice> slices;
  final bool showLabels;
  final double strokeWidth;

  ExpensePieChartPainter(
    this.slices, {
    this.showLabels = false,
    this.strokeWidth = 40.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (slices.isEmpty) return;

    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2;

    var startAngle = -90.0 * (3.1415926535 / 180.0); // Start bei 12 Uhr

    for (final slice in slices) {
      final sweepAngle = slice.value * 2 * 3.1415926535;

      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      // Zeichne den Bogen als Ring (donut style)
      final arcRect = Rect.fromCircle(
        center: center,
        radius: radius - strokeWidth / 2,
      );
      canvas.drawArc(arcRect, startAngle, sweepAngle, false, paint);

      // Optional: Zeichne Labels
      if (showLabels) {
        _drawLabel(canvas, center, radius, startAngle, sweepAngle, slice);
      }

      startAngle += sweepAngle;
    }

    // Zentraler Schatten für Tiefe
    final shadowPaint = Paint()
      ..color = Colors.black12
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, radius * 0.02, shadowPaint);
  }

  void _drawLabel(Canvas canvas, Offset center, double radius,
      double startAngle, double sweepAngle, ExpensePieSlice slice) {
    final labelAngle = startAngle + sweepAngle / 2;
    final labelRadius = radius - strokeWidth / 2;
    final labelPosition = Offset(
      center.dx + labelRadius * 0.7 * (labelRadius / radius) * cos(labelAngle),
      center.dy + labelRadius * 0.7 * (labelRadius / radius) * sin(labelAngle),
    );

    final textSpan = TextSpan(
      text: '${(slice.value * 100).toStringAsFixed(1)}%',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      labelPosition - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant ExpensePieChartPainter oldDelegate) {
    return oldDelegate.slices != slices ||
        oldDelegate.showLabels != showLabels ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Widget für das Ausgaben-Kreisdiagramm mit Legende
class ExpensePieChart extends StatelessWidget {
  final List<ExpensePieSlice> slices;
  final double size;
  final bool showLegend;
  final bool showLabels;
  final double strokeWidth;

  const ExpensePieChart({
    required this.slices,
    this.size = 240,
    this.showLegend = true,
    this.showLabels = false,
    this.strokeWidth = 40.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (slices.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Kreisdiagramm
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: ExpensePieChartPainter(
              slices,
              showLabels: showLabels,
              strokeWidth: strokeWidth,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        
        // Legende
        if (showLegend) ...[
          const SizedBox(height: 24),
          _buildLegend(),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
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
            Icon(
              Icons.pie_chart_outline,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'Noch keine Ausgaben',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            Text(
              'Erstelle deine erste geteilte Rechnung!',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: slices.map((slice) => _buildLegendItem(slice)).toList(),
    );
  }

  Widget _buildLegendItem(ExpensePieSlice slice) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: slice.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          slice.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${slice.amount.toStringAsFixed(0)}€)',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

/// Vereinfachte Version für kleine Anzeigen
class MiniExpensePieChart extends StatelessWidget {
  final List<ExpensePieSlice> slices;
  final double size;

  const MiniExpensePieChart({
    required this.slices,
    this.size = 120,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: ExpensePieChartPainter(
          slices,
          strokeWidth: size * 0.2, // Proportionale Dicke
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Math helper functions
double cos(double radians) => dart_math.cos(radians);
double sin(double radians) => dart_math.sin(radians);