// lib/features/dashboard/widgets/experiment/parameter_trend_chart.dart

import 'package:flutter/material.dart';
import 'dart:math' show sin;

class ParameterTrendChart extends StatelessWidget {
  final String parameter;
  final Color color;

  ParameterTrendChart({
    required this.parameter,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Implement actual chart using a charting library
    // For now, we'll show a placeholder with a simulated trend line
    return CustomPaint(
      painter: TrendLinePainter(color: color),
      child: Container(),
    );
  }
}

class TrendLinePainter extends CustomPainter {
  final Color color;

  TrendLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Create a simulated trend line
    var points = _generateSimulatedData(size);
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Draw grid lines
    _drawGrid(canvas, size);

    // Draw the trend line
    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.fill;

    for (var point in points) {
      canvas.drawCircle(point, 2, pointPaint);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.5;

    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Draw vertical grid lines
    for (int i = 0; i <= 8; i++) {
      final x = size.width * i / 8;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
  }

  List<Offset> _generateSimulatedData(Size size) {
    final points = <Offset>[];
    final random = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i <= 50; i++) {
      final x = size.width * i / 50;
      final normalizedSin = (sin((i + random) * 0.2) + 1) / 2;
      final noise = (random % 100) / 1000;
      final y = size.height * (0.3 + 0.4 * normalizedSin + noise);
      points.add(Offset(x, y));
    }

    return points;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


