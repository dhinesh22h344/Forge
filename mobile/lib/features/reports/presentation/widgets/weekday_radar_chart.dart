import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/weekday_stat.dart';

/// Spider/radar chart — one axis per weekday, radius = completion rate.
/// Hand-rolled with CustomPainter rather than a charting package: this is
/// the one shape in Reports that genuinely needs a painter (bars and the
/// heatmap are just decorated boxes), so it isn't worth a dependency.
class WeekdayRadarChart extends StatelessWidget {
  const WeekdayRadarChart({super.key, required this.stats});

  final List<WeekdayStat> stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _RadarPainter(
          values: [for (final s in stats) s.completionRate.clamp(0.0, 1.0)],
          labels: [for (final s in stats) s.weekday],
          gridColor: theme.dividerTheme.color ?? theme.colorScheme.outlineVariant,
          fillColor: theme.colorScheme.primary.withValues(alpha: 0.25),
          strokeColor: theme.colorScheme.primary,
          labelStyle: theme.textTheme.bodySmall ?? const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.values,
    required this.labels,
    required this.gridColor,
    required this.fillColor,
    required this.strokeColor,
    required this.labelStyle,
  });

  final List<double> values;
  final List<String> labels;
  final Color gridColor;
  final Color fillColor;
  final Color strokeColor;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    if (n < 3) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 22;
    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final fraction in const [0.25, 0.5, 0.75, 1.0]) {
      final ring = Path();
      for (var i = 0; i < n; i++) {
        final point = _pointAt(center, radius * fraction, i, n);
        if (i == 0) {
          ring.moveTo(point.dx, point.dy);
        } else {
          ring.lineTo(point.dx, point.dy);
        }
      }
      ring.close();
      canvas.drawPath(ring, gridPaint);
    }

    for (var i = 0; i < n; i++) {
      canvas.drawLine(center, _pointAt(center, radius, i, n), gridPaint);
    }

    final dataPath = Path();
    for (var i = 0; i < n; i++) {
      final point = _pointAt(center, radius * values[i], i, n);
      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();
    canvas.drawPath(dataPath, Paint()..color = fillColor..style = PaintingStyle.fill);
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    for (var i = 0; i < n; i++) {
      final point = _pointAt(center, radius + 14, i, n);
      final painter = TextPainter(text: TextSpan(text: labels[i], style: labelStyle), textDirection: TextDirection.ltr)
        ..layout();
      painter.paint(canvas, point - Offset(painter.width / 2, painter.height / 2));
    }
  }

  Offset _pointAt(Offset center, double radius, int i, int n) {
    final angle = (2 * math.pi * i / n) - (math.pi / 2);
    return center + Offset(math.cos(angle), math.sin(angle)) * radius;
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => oldDelegate.values != values || oldDelegate.strokeColor != strokeColor;
}
