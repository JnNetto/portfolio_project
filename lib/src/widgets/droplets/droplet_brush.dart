import 'dart:math' as math;

import 'package:flutter/material.dart';

class DropletPalette {
  final Color body;
  final Color rim;
  final Color highlight;

  const DropletPalette({
    required this.body,
    required this.rim,
    required this.highlight,
  });

  static const dark = DropletPalette(
    body: Color(0xFFBFE6FF),
    rim: Color(0xFFDDF3FF),
    highlight: Color(0xFFFFFFFF),
  );

  static const light = DropletPalette(
    body: Color(0xFF7FB3D5),
    rim: Color(0xFF47657A),
    highlight: Color(0xFFFFFFFF),
  );

  static DropletPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// Desenha uma gota d'água transparente. Compartilhado entre as gotas do
/// celular e as espalhadas pelo site, para que todas tenham o mesmo material.
class DropletBrush {
  final DropletPalette palette;

  final _fill = Paint();
  final _stroke = Paint()..style = PaintingStyle.stroke;
  final _caustic = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final _shine = Paint();

  DropletBrush(this.palette);

  void draw(
    Canvas canvas, {
    required Offset pos,
    required double radius,
    required Offset velocity,
    required double wobble,
    required double time,
    required double phase,
    double alpha = 1,
  }) {
    final r = radius;
    if (r < 0.6) return;

    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    // Estica na direção do movimento e oscila depois de um impulso.
    final speed = velocity.distance;
    final stretch = 1 + math.min(0.45, speed / 900);
    final w = wobble * math.sin(time * 16 + phase);
    final dir = speed > 1 ? math.atan2(velocity.dy, velocity.dx) : 0.0;
    canvas
      ..rotate(dir)
      ..scale(stretch * (1 + w), (1 - w) / stretch)
      ..rotate(-dir);

    if (r < 2.4) {
      _fill.color = palette.rim.withValues(alpha: 0.38 * alpha);
      canvas.drawCircle(Offset.zero, r, _fill);
      _fill.color = palette.highlight.withValues(alpha: 0.8 * alpha);
      canvas.drawCircle(Offset(-r * 0.3, -r * 0.3), r * 0.35, _fill);
      canvas.restore();
      return;
    }

    final rect = Rect.fromCircle(center: Offset.zero, radius: r);
    _fill
      ..color = const Color(0xFFFFFFFF)
      ..shader = RadialGradient(
        center: const Alignment(0.15, 0.25),
        radius: 0.95,
        colors: [
          palette.body.withValues(alpha: 0.02 * alpha),
          palette.body.withValues(alpha: 0.08 * alpha),
          palette.rim.withValues(alpha: 0.3 * alpha),
        ],
        stops: const [0, 0.72, 1],
      ).createShader(rect);
    canvas.drawCircle(Offset.zero, r, _fill);
    _fill.shader = null;

    // Luz refratada concentrada na borda inferior.
    _caustic
      ..strokeWidth = r * 0.16
      ..color = palette.highlight.withValues(alpha: 0.32 * alpha);
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: r * 0.68),
      0.35,
      1.5,
      false,
      _caustic,
    );

    _stroke
      ..strokeWidth = math.max(0.6, r * 0.07)
      ..color = palette.rim.withValues(alpha: 0.42 * alpha);
    canvas.drawCircle(Offset.zero, r, _stroke);

    // Reflexo especular.
    _shine.color = palette.highlight.withValues(alpha: 0.85 * alpha);
    canvas
      ..save()
      ..translate(-r * 0.36, -r * 0.38)
      ..rotate(-0.6)
      ..drawOval(
        Rect.fromCenter(center: Offset.zero, width: r * 0.5, height: r * 0.28),
        _shine,
      )
      ..restore();

    canvas.restore();
  }
}
