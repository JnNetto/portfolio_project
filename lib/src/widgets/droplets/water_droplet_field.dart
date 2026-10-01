import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:portfolio/src/widgets/droplets/orbit_reader.dart';

/// Gotas d'água flutuando em órbita ao redor de [child].
///
/// No web a órbita vem da câmera do <model-viewer>; nas outras plataformas,
/// do arraste capturado pelo [Listener]. Metade das gotas é pintada atrás do
/// [child] e metade na frente, conforme a profundidade projetada.
class WaterDropletField extends StatefulWidget {
  final Widget child;
  final int count;

  const WaterDropletField({super.key, required this.child, this.count = 70});

  @override
  State<WaterDropletField> createState() => _WaterDropletFieldState();
}

class _WaterDropletFieldState extends State<WaterDropletField>
    with SingleTickerProviderStateMixin {
  static const _defaultPhi = 78 * math.pi / 180;
  // Velocidade padrão do auto-rotate do model-viewer (~32deg/s).
  static const _autoRotateSpeed = 0.56;

  late final _sim = _DropletSim(widget.count);
  late final Ticker _ticker = createTicker(_onTick);
  final _reader = OrbitReader();

  Duration _last = Duration.zero;
  double _localTheta = 0;
  Offset? _localPointer;
  bool? _usingDom;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion && _ticker.isActive) {
      _ticker.stop();
    } else if (!reduceMotion && !_ticker.isActive) {
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
    final palette = Theme.of(context).brightness == Brightness.dark
        ? _DropletPalette.dark
        : _DropletPalette.light;

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
              _localTheta -= e.delta.dx * 0.012;
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

    return List.generate(count, (i) {
      final u = rnd.nextDouble();
      final size = u < 0.6
          ? lerp(1.4, 3.2)
          : u < 0.9
              ? lerp(3.2, 6.5)
              : lerp(6.5, 11);
      final heaviness = ((size - 1.4) / 9.6).clamp(0.0, 1.0);
      return _Droplet(
        angle: (i / count) * math.pi * 2 + lerp(-0.25, 0.25),
        ring: lerp(0.42, 1.0),
        height: lerp(-1, 1),
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

class _DropletPalette {
  final Color body;
  final Color rim;
  final Color highlight;

  const _DropletPalette({
    required this.body,
    required this.rim,
    required this.highlight,
  });

  static const dark = _DropletPalette(
    body: Color(0xFFBFE6FF),
    rim: Color(0xFFDDF3FF),
    highlight: Color(0xFFFFFFFF),
  );

  static const light = _DropletPalette(
    body: Color(0xFF7FB3D5),
    rim: Color(0xFF47657A),
    highlight: Color(0xFFFFFFFF),
  );
}

class _DropletPainter extends CustomPainter {
  final _DropletSim sim;
  final bool front;
  final _DropletPalette palette;

  final _fill = Paint();
  final _stroke = Paint()..style = PaintingStyle.stroke;
  final _caustic = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final _shine = Paint();

  _DropletPainter(this.sim, {required this.front, required this.palette})
      : super(repaint: sim);

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
      _drawDroplet(canvas, d, alpha);
    }
  }

  void _drawDroplet(Canvas canvas, _Droplet d, double alpha) {
    final r = d.radius;
    if (r < 0.6) return;

    canvas.save();
    canvas.translate(d.pos.dx, d.pos.dy);

    // Estica na direção do movimento e oscila depois de um impulso.
    final speed = d.screenVel.distance;
    final stretch = 1 + math.min(0.45, speed / 900);
    final w = d.wobble * math.sin(sim.time * 16 + d.phase);
    final dir = speed > 1 ? math.atan2(d.screenVel.dy, d.screenVel.dx) : 0.0;
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

  @override
  bool shouldRepaint(_DropletPainter old) =>
      old.sim != sim || old.front != front || old.palette != palette;
}
