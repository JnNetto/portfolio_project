import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:portfolio/src/widgets/droplets/droplet_brush.dart';

/// Gotas espalhadas pela página inteira, em três profundidades:
///
/// * longe: pequenas e apagadas, rolam mais devagar que o conteúdo;
/// * meio: atrás do conteúdo, somem sob os cartões;
/// * perto: na frente do conteúdo, maiores e rolam mais rápido.
///
/// A diferença de velocidade na rolagem (parallax) é o que dá a sensação
/// de profundidade. [child] deve ter fundo transparente.
class SiteDroplets extends StatefulWidget {
  final Widget child;
  final int count;

  const SiteDroplets({super.key, required this.child, this.count = 110});

  @override
  State<SiteDroplets> createState() => _SiteDropletsState();
}

class _SiteDropletsState extends State<SiteDroplets>
    with SingleTickerProviderStateMixin {
  late final _sim = _SiteSim(widget.count);
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  bool _visible = true;

  /// Segundos sem rolagem nem ponteiro. Parada, a página não precisa de
  /// frames: depois de um tempo quieta, o ticker dorme até o próximo gesto.
  double _idle = 0;
  static const _sleepAfter = 2.0;

  @override
  void initState() {
    super.initState();
    // No initState, e não com `late` preguiçoso: um widget descartado sem
    // nunca ter animado criaria o ticker dentro do dispose() e quebraria.
    _ticker = createTicker(_onTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.sizeOf(context);
    // Em telas de paisagem (computador) as gotas ficam só no celular 3D.
    _visible = size.height > size.width;
    if (!_canAnimate && _ticker.isActive) {
      _ticker.stop();
    } else {
      _wake();
    }
  }

  bool get _canAnimate => _visible && !MediaQuery.disableAnimationsOf(context);

  void _wake() {
    _idle = 0;
    if (_canAnimate && !_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _sim.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 1 / 30);
    _last = elapsed;
    _sim.step(dt, elapsed.inMicroseconds / 1e6);
    _idle += dt;
    // Dorme só depois que as gotas assentaram, para não congelar no meio.
    if (_idle > _sleepAfter && _sim.energy < 2) _ticker.stop();
  }

  bool _onScroll(ScrollNotification n) {
    // Só a rolagem principal; carrosséis horizontais não movem as gotas.
    if (n.depth == 0 && n.metrics.axis == Axis.vertical) {
      _sim
        ..scroll = n.metrics.pixels
        ..maxScroll = n.metrics.maxScrollExtent;
      _wake();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final palette = DropletPalette.of(context);

    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: NotificationListener<ScrollMetricsNotification>(
        onNotification: (n) {
          if (n.depth == 0 && n.metrics.axis == Axis.vertical) {
            _sim.maxScroll = n.metrics.maxScrollExtent;
          }
          return false;
        },
        child: MouseRegion(
          onExit: (_) => _sim.pointer = null,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerHover: (e) {
              _sim.pointer = e.localPosition;
              _wake();
            },
            onPointerMove: (e) {
              _sim.pointer = e.localPosition;
              _wake();
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _SitePainter(
                        _sim,
                        front: false,
                        visible: _visible,
                        palette: palette,
                      ),
                    ),
                  ),
                ),
                widget.child,
                IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _SitePainter(
                        _sim,
                        front: true,
                        visible: _visible,
                        palette: palette,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _Depth { far, mid, near }

class _SiteDroplet {
  final double nx;
  final double ny;
  final _Depth depth;
  final double size;
  final double parallax;
  final double alpha;
  final double phase;
  final double bobSpeed;
  final double stiffness;
  final double damping;

  // Deslocamento em relação à posição de repouso (inércia + ponteiro).
  Offset offset = Offset.zero;
  Offset offsetVel = Offset.zero;
  double wobble = 0;
  Offset pos = Offset.zero;

  _SiteDroplet({
    required this.nx,
    required this.ny,
    required this.depth,
    required this.size,
    required this.parallax,
    required this.alpha,
    required this.phase,
    required this.bobSpeed,
    required this.stiffness,
  }) : damping = 2 * math.sqrt(stiffness) * 0.35;
}

class _SiteSim extends ChangeNotifier {
  final List<_SiteDroplet> droplets;

  double scroll = 0;
  double maxScroll = 0;
  Offset? pointer;
  Size size = Size.zero;

  double _time = 0;
  double _lastScroll = 0;

  _SiteSim(int count) : droplets = _seed(count);

  /// Quanto as gotas ainda estão se mexendo (soma das velocidades).
  double get energy =>
      droplets.fold(0.0, (sum, d) => sum + d.offsetVel.distance);

  static List<_SiteDroplet> _seed(int count) {
    final rnd = math.Random(23);
    double lerp(double a, double b) => a + (b - a) * rnd.nextDouble();
    double gaussian() {
      final u1 = 1 - rnd.nextDouble();
      return math.sqrt(-2 * math.log(u1)) *
          math.cos(2 * math.pi * rnd.nextDouble());
    }

    // Aglomerados de tamanhos variados, como respingos, mais gotas soltas.
    final clusters = List.generate(
      16,
      (_) => (
        x: lerp(0.02, 0.98),
        y: lerp(0, 1),
        spreadX: lerp(0.03, 0.12),
        spreadY: lerp(0.006, 0.03),
      ),
    );

    return List.generate(count, (_) {
      final double nx;
      final double ny;
      if (rnd.nextDouble() < 0.6) {
        final c = clusters[rnd.nextInt(clusters.length)];
        nx = c.x + gaussian() * c.spreadX;
        ny = c.y + gaussian() * c.spreadY;
      } else {
        nx = lerp(0, 1);
        ny = lerp(0, 1);
      }

      final u = rnd.nextDouble();
      final depth = u < 0.45
          ? _Depth.far
          : u < 0.88
              ? _Depth.mid
              : _Depth.near;
      final (size, parallax, alpha) = switch (depth) {
        _Depth.far => (lerp(1.2, 3.2), 0.55, 0.5),
        _Depth.mid => (lerp(2.2, 7), 0.85, 0.8),
        _Depth.near => (lerp(5, 13), 1.2, 0.95),
      };

      return _SiteDroplet(
        nx: nx,
        ny: ny,
        depth: depth,
        size: size,
        parallax: parallax,
        alpha: alpha,
        phase: lerp(0, math.pi * 2),
        bobSpeed: lerp(0.3, 0.9),
        // Gotas maiores demoram mais para voltar ao lugar.
        stiffness: 60 - size * 3,
      );
    });
  }

  void step(double dt, double time) {
    _time = time;
    final scrollDelta = scroll - _lastScroll;
    _lastScroll = scroll;

    if (dt > 0) {
      final decay = math.exp(-2.8 * dt);
      for (final d in droplets) {
        // Inércia: a gota resiste um pouco à rolagem e depois alcança.
        d.offset += Offset(0, scrollDelta * d.parallax * 0.15);

        var force = -d.offset * d.stiffness - d.offsetVel * d.damping;
        final p = pointer;
        if (p != null) {
          final away = d.pos - p;
          final dist = away.distance;
          if (dist > 0.001 && dist < 120) {
            final k = math.pow(1 - dist / 120, 2).toDouble();
            force += away / dist * (2600 * k);
            d.wobble = math.min(0.35, d.wobble + k * dt * 2);
          }
        }
        d.offsetVel += force * dt;
        d.offset += d.offsetVel * dt;
        if (d.offset.distance > 70) {
          d.offset = d.offset / d.offset.distance * 70;
        }
        d.wobble = math.min(
          0.35,
          d.wobble * decay + d.offsetVel.distance * dt * 0.004,
        );
      }
    }
    if (!size.isEmpty) layout(size);
    notifyListeners();
  }

  void layout(Size viewport) {
    size = viewport;
    for (final d in droplets) {
      // Cada profundidade percorre uma "página" de altura diferente; assim
      // todas cobrem o site inteiro, mas rolam em velocidades diferentes.
      final travel = viewport.height + maxScroll * d.parallax;
      final bob = Offset(
        math.sin(_time * d.bobSpeed + d.phase) * 3,
        math.cos(_time * d.bobSpeed * 0.7 + d.phase) * 4,
      );
      d.pos = Offset(
            d.nx * viewport.width,
            d.ny * travel - scroll * d.parallax,
          ) +
          d.offset +
          bob;
    }
  }

  double get time => _time;
}

class _SitePainter extends CustomPainter {
  final _SiteSim sim;
  final bool front;
  final bool visible;
  final DropletBrush brush;

  _SitePainter(
    this.sim, {
    required this.front,
    required this.visible,
    required DropletPalette palette,
  })  : brush = DropletBrush(palette),
        super(repaint: sim);

  @override
  void paint(Canvas canvas, Size size) {
    // O tamanho só é conhecido aqui; com ele, o step calcula as posições.
    if (!visible) return;
    if (sim.size != size) sim.layout(size);

    for (final d in sim.droplets) {
      if ((d.depth == _Depth.near) != front) continue;
      final r = d.size;
      if (d.pos.dy < -r * 2 || d.pos.dy > size.height + r * 2) continue;
      brush.draw(
        canvas,
        pos: d.pos,
        radius: r,
        velocity: d.offsetVel,
        wobble: d.wobble,
        time: sim.time,
        phase: d.phase,
        alpha: d.alpha,
      );
    }
  }

  @override
  bool shouldRepaint(_SitePainter old) =>
      old.sim != sim ||
      old.visible != visible ||
      old.front != front ||
      old.brush.palette != brush.palette;
}
