import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class DropletPalette {
  /// Tom da água: aparece onde a luz atravessa a gota.
  final Color body;

  /// Sombra interna: a borda espessa e o topo invertido de uma lente cheia.
  final Color edge;

  /// Contorno fino que separa a gota do fundo.
  final Color rim;
  final Color highlight;

  const DropletPalette({
    required this.body,
    required this.edge,
    required this.rim,
    required this.highlight,
  });

  static const dark = DropletPalette(
    body: Color(0xFF7CC4FF),
    edge: Color(0xFF020817),
    rim: Color(0xFFCFEAFF),
    highlight: Color(0xFFFFFFFF),
  );

  // No claro o branco some no fundo: quem desenha a gota é a borda escura.
  static const light = DropletPalette(
    body: Color(0xFF4A90C8),
    edge: Color(0xFF16324F),
    rim: Color(0xFF1F4E79),
    highlight: Color(0xFFFFFFFF),
  );

  static DropletPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// Desenha uma gota d'água transparente. Compartilhado entre as gotas do
/// celular e as espalhadas pelo site, para que todas tenham o mesmo material.
///
/// A gota completa (gradiente, brilho, contorno e reflexo) é desenhada uma
/// única vez numa imagem por tema; a cada frame cada gota só "carimba" essa
/// imagem com a transformação dela. Bem mais barato que recriar o gradiente
/// e fazer cinco desenhos por gota.
class DropletBrush {
  final DropletPalette palette;

  static const _spriteSize = 128.0;
  static const _spriteRadius = 48.0; // folga para a sombra caber no sprite
  static final _sprites = <DropletPalette, ui.Image>{};

  final _fill = Paint();
  final _stamp = Paint()..filterQuality = FilterQuality.low;

  DropletBrush(this.palette);

  ui.Image get _sprite => _sprites[palette] ??= _renderSprite(palette);

  /// Uma gota d'água é uma lente cheia, não uma película como a bolha:
  /// borda escura e espessa (Fresnel), topo escurecido (o céu aparece
  /// invertido), luz concentrada embaixo (cáustica) e um reflexo pequeno e
  /// nítido em cima.
  static ui.Image _renderSprite(DropletPalette palette) {
    const r = _spriteRadius;
    const c = Offset(_spriteSize / 2, _spriteSize / 2);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final rect = Rect.fromCircle(center: c, radius: r);

    // Sombra suave deslocada: é o que faz o olho ler "gota no vidro".
    canvas.drawCircle(
      c + const Offset(r * 0.1, r * 0.16),
      r * 0.96,
      Paint()
        ..color = palette.edge.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Corpo: claro embaixo, onde a luz atravessa; escuro nas bordas.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.45),
          radius: 1.05,
          colors: [
            palette.body.withValues(alpha: 0.30),
            palette.body.withValues(alpha: 0.10),
            palette.edge.withValues(alpha: 0.42),
          ],
          stops: const [0, 0.55, 1],
        ).createShader(rect),
    );

    // Metade de cima escurecida: o reflexo invertido do que está acima.
    canvas
      ..save()
      ..clipPath(Path()..addOval(rect))
      ..drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              palette.edge.withValues(alpha: 0.32),
              palette.edge.withValues(alpha: 0),
            ],
          ).createShader(rect),
      )
      ..restore();

    // Cáustica: a luz focada pela lente vira uma mancha clara e difusa na
    // base (um arco aqui faria a gota parecer um anel, como uma bolha).
    canvas
      ..save()
      ..clipPath(Path()..addOval(rect))
      ..drawOval(
        Rect.fromCenter(
          center: c + const Offset(r * 0.05, r * 0.5),
          width: r * 1.2,
          height: r * 0.6,
        ),
        Paint()
          ..color = palette.highlight.withValues(alpha: 0.38)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      )
      ..restore();

    // Contorno quase imperceptível, mais forte embaixo, onde a luz sai.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.03
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.rim.withValues(alpha: 0.15),
            palette.rim.withValues(alpha: 0.55),
          ],
        ).createShader(rect),
    );

    // Reflexo especular: pequeno e nítido, mais um ponto de brilho.
    canvas
      ..save()
      ..translate(c.dx - r * 0.33, c.dy - r * 0.42)
      ..rotate(-0.55)
      ..drawOval(
        Rect.fromCenter(center: Offset.zero, width: r * 0.46, height: r * 0.24),
        Paint()..color = palette.highlight.withValues(alpha: 0.95),
      )
      ..restore();
    canvas.drawCircle(
      c + const Offset(-r * 0.02, -r * 0.62),
      r * 0.06,
      Paint()..color = palette.highlight.withValues(alpha: 0.8),
    );

    final picture = recorder.endRecording();
    final image = picture.toImageSync(_spriteSize.toInt(), _spriteSize.toInt());
    picture.dispose();
    return image;
  }

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
    if (speed > 1 || w != 0) {
      final dir = speed > 1 ? math.atan2(velocity.dy, velocity.dx) : 0.0;
      canvas
        ..rotate(dir)
        ..scale(stretch * (1 + w), (1 - w) / stretch)
        ..rotate(-dir);
    }

    if (r < 2.4) {
      // Pequena demais para os detalhes: dois círculos bastam.
      _fill.color = palette.edge.withValues(alpha: 0.35 * alpha);
      canvas.drawCircle(Offset.zero, r, _fill);
      _fill.color = palette.highlight.withValues(alpha: 0.8 * alpha);
      canvas.drawCircle(Offset(-r * 0.3, -r * 0.3), r * 0.35, _fill);
    } else {
      final sprite = _sprite;
      final half = r * (_spriteSize / 2) / _spriteRadius;
      _stamp.color = Color.fromRGBO(255, 255, 255, alpha);
      canvas.drawImageRect(
        sprite,
        const Rect.fromLTWH(0, 0, _spriteSize, _spriteSize),
        Rect.fromCircle(center: Offset.zero, radius: half),
        _stamp,
      );
    }
    canvas.restore();
  }
}
