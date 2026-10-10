import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:portfolio/src/utils/viewport_visibility.dart';
import 'package:portfolio/src/widgets/droplets/droplet_brush.dart';
import 'package:portfolio/src/widgets/droplets/orbit_reader.dart';

/// Gotas d'água flutuando em órbita ao redor de [child].
///
/// No web a órbita vem da câmera do <model-viewer>; nas outras plataformas,
/// do arraste capturado pelo [Listener]. Metade das gotas é pintada atrás do
/// [child] e metade na frente, conforme a profundidade projetada.
class WaterDropletField extends StatefulWidget {
  final Widget child;
  final int count;

  /// Chamado uma vez, quando o visitante gira o modelo pela primeira vez.
  final VoidCallback? onUserOrbit;

  /// No modo fixo o modelo não acompanha o arraste, e as gotas também não.
  final bool followDrag;

  const WaterDropletField({
    super.key,
    required this.child,
    this.count = 70,
    this.onUserOrbit,
    this.followDrag = true,
  });

  @override
  State<WaterDropletField> createState() => _WaterDropletFieldState();
}

class _WaterDropletFieldState extends State<WaterDropletField>
    with SingleTickerProviderStateMixin, ViewportVisibility {
  static const _defaultPhi = 78 * math.pi / 180;
  // Velocidade padrão do auto-rotate do model-viewer (~32deg/s).
  static const _autoRotateSpeed = 0.56;

  late final _sim = _DropletSim(widget.count);
  late final Ticker _ticker;
  final _reader = OrbitReader();

  Duration _last = Duration.zero;
  double _localTheta = 0;
  Offset? _localPointer;
  bool? _usingDom;
  double? _lastCameraTheta;
  bool _userOrbited = false;

  void _markUserOrbit() {
    if (_userOrbited) return;
    _userOrbited = true;
    widget.onUserOrbit?.call();
  }

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
    _syncTicker();
  }

  @override
  void onViewportVisibilityChanged(bool visible) => _syncTicker();

  /// Só anima com o celular na tela e sem "reduzir movimento".
  void _syncTicker() {
    final animate =
        visibleInViewport && !MediaQuery.disableAnimationsOf(context);
    if (!animate && _ticker.isActive) {
      _ticker.stop();
    } else if (animate && !_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _reader.dispose();
    _sim.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 1 / 30);
    _last = elapsed;

    final reading = _reader.read();
    final usingDom = reading != null;
    final double theta;
    final double phi;
    var zoom = 1.0;

    if (reading != null) {
      final last = _lastCameraTheta;
      if (last != null && (reading.cameraTheta - last).abs() > 0.002) {
        _markUserOrbit();
      }
      _lastCameraTheta = reading.cameraTheta;
      theta = reading.theta;
      phi = reading.phi;
      _sim.baseRadius ??= reading.radius;
      if (reading.radius > 0) zoom = _sim.baseRadius! / reading.radius;
    } else {
      _localTheta -= _autoRotateSpeed * dt;
      theta = _localTheta;
      phi = _defaultPhi;
    }

    // Troca de fonte (ex.: model-viewer terminou de carregar): sem salto.
    if (_usingDom != usingDom) {
      _usingDom = usingDom;
      _sim.snap(theta);
    }

    _sim.step(
      dt: dt,
      time: elapsed.inMicroseconds / 1e6,
      theta: theta,
      phi: phi,
      zoom: zoom,
      pointer: reading?.pointer ?? _localPointer,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = DropletPalette.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _DropletPainter(_sim, front: false, palette: palette),
            ),
          ),
        ),
        MouseRegion(
          onExit: (_) => _localPointer = null,
          child: Listener(
            onPointerHover: (e) => _localPointer = e.localPosition,
            onPointerDown: (e) => _localPointer = e.localPosition,
            onPointerMove: (e) {
              _localPointer = e.localPosition;
              if (!widget.followDrag) return;
              _localTheta -= e.delta.dx * 0.012;
              if (e.delta.dx.abs() > 2) _markUserOrbit();
            },
            child: widget.child,
          ),
        ),
        IgnorePointer(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _DropletPainter(_sim, front: true, palette: palette),
            ),
          ),
        ),
      ],
    );
  }
}

class _Droplet {
  double angle;
  final double ring;
  final double height;
  final double size;
  final double phase;
  final double bobAmp;
  final double bobSpeed;
  final double drift;
  final double stiffness;
  final double damping;

  // Ângulo de câmera "visto" pela gota: segue a câmera com atraso de mola.
  double theta = 0;
  double thetaVel = 0;
  // Afastamento radial causado pela rotação (força centrífuga).
  double push = 0;
  double pushVel = 0;
  // Deslocamento em tela causado pelo ponteiro.
  Offset offset = Offset.zero;
  Offset offsetVel = Offset.zero;
  double wobble = 0;

  Offset pos = Offset.zero;
  Offset screenVel = Offset.zero;
  double radius = 0;
  double depth = 0;
  bool hasPos = false;

  _Droplet({
    required this.angle,
    required this.ring,
    required this.height,
    required this.size,
    required this.phase,
    required this.bobAmp,
    required this.bobSpeed,
    required this.drift,
    required this.stiffness,
  }) : damping = 2 * math.sqrt(stiffness) * 0.38;
}

class _DropletSim extends ChangeNotifier {
  final List<_Droplet> droplets;
  double? baseRadius;

  double _camTheta = 0;
  double _phi = 78 * math.pi / 180;
  double _zoom = 1;
  double _time = 0;
  double _dt = 0;

  int _frame = 0;
  int _projectedFrame = -1;
  Size _projectedSize = Size.zero;

  _DropletSim(int count) : droplets = _seed(count);

  static List<_Droplet> _seed(int count) {
    final rnd = math.Random(7);
    double lerp(double a, double b) => a + (b - a) * rnd.nextDouble();

    // Alguns "bolsões" onde as gotas se acumulam, para fugir do anel
    // uniforme: cada gota cai num bolsão ou fica solta.
    final pockets = List.generate(
      7,
      (_) => (angle: lerp(0, math.pi * 2), height: lerp(-1, 1)),
    );

    return List.generate(count, (i) {
      final u = rnd.nextDouble();
      final size = u < 0.6
          ? lerp(1.4, 3.2)
          : u < 0.9
              ? lerp(3.2, 6.5)
              : lerp(6.5, 11);
      final heaviness = ((size - 1.4) / 9.6).clamp(0.0, 1.0);

      final double angle;
      final double height;
      if (rnd.nextDouble() < 0.65) {
        final p = pockets[rnd.nextInt(pockets.length)];
        angle = p.angle + _gaussian(rnd) * 0.45;
        height = (p.height + _gaussian(rnd) * 0.22).clamp(-1.25, 1.25);
      } else {
        angle = lerp(0, math.pi * 2);
        height = lerp(-1.25, 1.25);
      }

      return _Droplet(
        angle: angle,
        // Maioria perto do aparelho, algumas bem afastadas.
        ring: 0.38 + math.pow(rnd.nextDouble(), 1.6) * 0.8,
        height: height,
        size: size,
        phase: lerp(0, math.pi * 2),
        bobAmp: lerp(0.01, 0.035),
        bobSpeed: lerp(0.5, 1.3),
        drift: lerp(-0.05, 0.05),
        // Gotas maiores são mais "pesadas": atrasam e balançam mais.
        stiffness: 70 - 52 * heaviness,
      );
    });
  }

  static double _gaussian(math.Random rnd) {
    final u1 = 1 - rnd.nextDouble();
    final u2 = rnd.nextDouble();
    return math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2);
  }

  void snap(double theta) {
    _camTheta = theta;
    for (final d in droplets) {
      d
        ..theta = theta
        ..thetaVel = 0;
    }
  }

  void step({
    required double dt,
    required double time,
    required double theta,
    required double phi,
    required double zoom,
    required Offset? pointer,
  }) {
    final delta = math.atan2(
      math.sin(theta - _camTheta),
      math.cos(theta - _camTheta),
    );
    _camTheta += delta;
    _phi = phi;
    _zoom = zoom;
    _time = time;
    _dt = dt;

    if (dt > 0) {
      final decay = math.exp(-2.8 * dt);
      for (final d in droplets) {
        d.angle += d.drift * dt;

        final lag = _camTheta - d.theta;
        d.thetaVel += (d.stiffness * lag - d.damping * d.thetaVel) * dt;
        d.theta += d.thetaVel * dt;

        final spin = d.thetaVel.abs();
        d.pushVel += (spin * 1.2 - 60 * d.push - 9 * d.pushVel) * dt;
        d.push += d.pushVel * dt;

        d.wobble = math.min(0.35, d.wobble * decay + lag.abs() * dt * 6);

        var force = -d.offset * 30 - d.offsetVel * 6;
        if (pointer != null && d.hasPos) {
          final away = d.pos - pointer;
          final dist = away.distance;
          if (dist > 0.001 && dist < 110) {
            final k = math.pow(1 - dist / 110, 2).toDouble();
            force += away / dist * (2600 * k);
            d.wobble = math.min(0.35, d.wobble + k * dt * 2);
          }
        }
        d.offsetVel += force * dt;
        d.offset += d.offsetVel * dt;
      }
    }

    _frame++;
    notifyListeners();
  }

  void project(Size size) {
    if (_projectedFrame == _frame && _projectedSize == size) return;
    _projectedFrame = _frame;
    _projectedSize = size;
    if (size.isEmpty) return;

    final center = size.center(Offset.zero);
    final unit = math.min(size.width * 0.5, size.height * 0.42) * _zoom;
    final heightRange = size.height * 0.46 / unit * _zoom;
    final elevation = math.pi / 2 - _phi;
    final cosE = math.cos(elevation);
    final sinE = math.sin(elevation);
    const focal = 3.2;

    for (final d in droplets) {
      final a = d.angle - d.theta;
      final r = d.ring * (1 + d.push);
      final x = r * math.sin(a);
      final z = r * math.cos(a);
      final y = d.height * heightRange +
          math.sin(_time * d.bobSpeed + d.phase) * d.bobAmp * 4;

      final yv = y * cosE - z * sinE;
      final zv = y * sinE + z * cosE;
      final s = focal / (focal - zv);

      final pos = center + Offset(x * s * unit, -yv * s * unit) + d.offset;
      if (d.hasPos && _dt > 0) {
        final v = (pos - d.pos) / _dt;
        d.screenVel = Offset.lerp(d.screenVel, v, 0.3)!;
      }
      d
        ..pos = pos
        ..hasPos = true
        ..radius = d.size * s * math.sqrt(_zoom)
        ..depth = zv;
    }
  }

  double get time => _time;
}

class _DropletPainter extends CustomPainter {
  final _DropletSim sim;
  final bool front;
  final DropletBrush brush;

  _DropletPainter(this.sim,
      {required this.front, required DropletPalette palette})
      : brush = DropletBrush(palette),
        super(repaint: sim);

  @override
  void paint(Canvas canvas, Size size) {
    sim.project(size);

    final layer = [
      for (final d in sim.droplets)
        if ((d.depth >= 0) == front) d,
    ]..sort((a, b) => a.depth.compareTo(b.depth));

    for (final d in layer) {
      // Gotas atrás do aparelho ficam mais apagadas, como fora de foco.
      final alpha = front ? 1.0 : (0.75 + d.depth * 0.35).clamp(0.35, 0.75);
      brush.draw(
        canvas,
        pos: d.pos,
        radius: d.radius,
        velocity: d.screenVel,
        wobble: d.wobble,
        time: sim.time,
        phase: d.phase,
        alpha: alpha,
      );
    }
  }

  @override
  bool shouldRepaint(_DropletPainter old) =>
      old.sim != sim ||
      old.front != front ||
      old.brush.palette != brush.palette;
}
