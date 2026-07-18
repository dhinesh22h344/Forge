import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The app's signature identity mark — a living flame whose height, sway,
/// and heat read as one continuous cross-category consistency signal rather
/// than any single habit or category. [intensity] (0.0-1.0) is expected to
/// come from [DashboardSummary.consistencyScore] or an equivalent aggregate;
/// everywhere this widget appears (dashboard header, streak stat, elsewhere)
/// the same shape/motion language keeps the identity recognizable.
///
/// It never fully goes out — even at intensity 0 there's a small ember,
/// because a dead flame reads as "broken app", not "start a streak".
class ForgeFlame extends StatefulWidget {
  const ForgeFlame({
    super.key,
    required this.intensity,
    this.size = 120,
    this.showAura = true,
    this.showSparks = true,
  });

  /// 0.0 (cold ember) to 1.0 (full blaze). Values outside that range are
  /// clamped.
  final double intensity;
  final double size;
  final bool showAura;
  final bool showSparks;

  @override
  State<ForgeFlame> createState() => _ForgeFlameState();
}

class _ForgeFlameState extends State<ForgeFlame> with TickerProviderStateMixin {
  late final AnimationController _flicker;
  late final AnimationController _intensityController;
  late Tween<double> _intensityTween;

  double get _target => widget.intensity.clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    _flicker = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    _intensityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    // First appearance "ignites" from a low ember rather than snapping
    // straight to the target — a small piece of the living quality.
    _intensityTween = Tween(begin: math.min(0.12, _target), end: _target);
    _intensityController.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant ForgeFlame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.intensity != widget.intensity) {
      final displayed = _intensityTween.evaluate(_intensityController);
      _intensityTween = Tween(begin: displayed, end: _target);
      _intensityController.duration = const Duration(milliseconds: 700);
      _intensityController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _flicker.dispose();
    _intensityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final accent = theme.colorScheme.secondary;
    final ember = Color.lerp(
      theme.colorScheme.onSurface.withValues(alpha: 0.25),
      primary,
      0.35,
    )!;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_flicker, _intensityController]),
        builder: (context, _) {
          return CustomPaint(
            painter: _FlamePainter(
              t: _flicker.value,
              intensity: _intensityTween.evaluate(_intensityController),
              primary: primary,
              accent: accent,
              ember: ember,
              showAura: widget.showAura,
              showSparks: widget.showSparks,
            ),
          );
        },
      ),
    );
  }
}

class _FlamePainter extends CustomPainter {
  _FlamePainter({
    required this.t,
    required this.intensity,
    required this.primary,
    required this.accent,
    required this.ember,
    required this.showAura,
    required this.showSparks,
  });

  final double t;
  final double intensity;
  final Color primary;
  final Color accent;
  final Color ember;
  final bool showAura;
  final bool showSparks;

  static const double _tau = 2 * math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = t * _tau;
    final cx = size.width / 2;
    final baseY = size.height * 0.96;
    final sway = intensity; // more life at higher intensity, calmer near-ember

    if (showAura) {
      final auraPaint = Paint()
        ..color = accent.withValues(alpha: 0.05 + 0.16 * intensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      canvas.drawCircle(
        Offset(cx, baseY - size.height * 0.35),
        size.width * 0.55,
        auraPaint,
      );
    }

    // Base ember — always present, even at intensity 0.
    final emberPaint = Paint()
      ..color = Color.lerp(ember, accent, intensity * 0.6)!;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, baseY - 1),
        width: size.width * 0.22,
        height: size.height * 0.05,
      ),
      emberPaint,
    );

    final flameHeight = size.height * (0.22 + 0.66 * intensity);

    _drawTongue(
      canvas,
      size,
      baseY: baseY,
      cx: cx,
      height: flameHeight * (0.92 + 0.08 * math.sin(phase + 0.4)),
      width: size.width * 0.46,
      lean: math.sin(phase * 0.55 + 0.4) * size.width * 0.05 * sway,
      waist: 0.58 + 0.08 * math.sin(phase * 0.4),
      color: Color.lerp(ember, primary, intensity)!.withValues(alpha: 0.65),
    );

    _drawTongue(
      canvas,
      size,
      baseY: baseY,
      cx: cx,
      height: flameHeight * (0.78 + 0.1 * math.sin(phase * 1.3 + 2.1)),
      width: size.width * 0.34,
      lean: math.sin(phase * 0.9 + 1.6) * size.width * 0.06 * sway,
      waist: 0.52 + 0.1 * math.sin(phase * 0.7 + 1.0),
      color: Color.lerp(primary, accent, 0.55)!.withValues(alpha: 0.9),
    );

    _drawTongue(
      canvas,
      size,
      baseY: baseY,
      cx: cx,
      height: flameHeight * (0.5 + 0.08 * math.sin(phase * 1.7 + 4.0)),
      width: size.width * 0.2,
      lean: math.sin(phase * 1.4 + 3.2) * size.width * 0.05 * sway,
      waist: 0.5,
      color: Color.lerp(accent, Colors.white, 0.22 * intensity)!,
    );

    if (showSparks && intensity > 0.5) {
      _drawSparks(canvas, size, cx: cx, baseY: baseY, phase: phase);
    }
  }

  void _drawTongue(
    Canvas canvas,
    Size size, {
    required double baseY,
    required double cx,
    required double height,
    required double width,
    required double lean,
    required double waist,
    required Color color,
  }) {
    if (height <= 1) return;
    final tipY = baseY - height;
    final tipX = cx + lean;
    final path = Path()
      ..moveTo(cx - width / 2, baseY)
      ..cubicTo(
        cx - width * waist,
        baseY - height * 0.55,
        tipX - width * 0.18,
        tipY + height * 0.35,
        tipX,
        tipY,
      )
      ..cubicTo(
        tipX + width * 0.18,
        tipY + height * 0.35,
        cx + width * waist,
        baseY - height * 0.55,
        cx + width / 2,
        baseY,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawSparks(
    Canvas canvas,
    Size size, {
    required double cx,
    required double baseY,
    required double phase,
  }) {
    const seeds = [0.1, 0.4, 0.7, 0.92];
    final sparkPaint = Paint();
    for (var i = 0; i < seeds.length; i++) {
      final seed = seeds[i];
      final progress = (t * (1.4 + seed) + seed) % 1.0;
      final riseDistance = size.height * 0.7;
      final y = baseY - size.height * 0.25 - progress * riseDistance;
      final x = cx + math.sin(progress * 6 + seed * 10) * size.width * 0.22;
      final opacity = (1 - progress) * (intensity - 0.5) * 2;
      if (opacity <= 0) continue;
      sparkPaint.color = accent.withValues(alpha: opacity.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), size.width * 0.02, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FlamePainter oldDelegate) => true;
}
