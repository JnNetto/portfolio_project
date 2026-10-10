import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:portfolio/src/utils/app_fonts.dart';

/// Capa gerada a partir dos dados do projeto: gradiente próprio, monograma e
/// ondas concêntricas que conversam com as gotas d'água do site.
class ProjectCover extends StatefulWidget {
  final Map<String, dynamic> project;

  /// Medida de referência: tipografia e espaçamentos derivam dela.
  final double scale;
  final bool front;

  const ProjectCover({
    super.key,
    required this.project,
    required this.scale,
    required this.front,
  });

  static const _gradients = [
    [Color(0xFF14532D), Color(0xFF052E16)],
    [Color(0xFF0F766E), Color(0xFF042F2E)],
    [Color(0xFF1E3A8A), Color(0xFF0B1220)],
    [Color(0xFF581C87), Color(0xFF1E1B4B)],
    [Color(0xFF9A3412), Color(0xFF2A0F06)],
    [Color(0xFF155E75), Color(0xFF082F49)],
    [Color(0xFF3730A3), Color(0xFF111827)],
    [Color(0xFF9F1239), Color(0xFF2A0A14)],
  ];

  static List<Color> colorsFor(String name) =>
      _gradients[name.codeUnits.fold(0, (a, b) => a + b) % _gradients.length];

  /// Liga a capa no carrossel ao cabeçalho do detalhe do projeto.
  static String heroTag(Map<String, dynamic> project) =>
      'project-cover-${project['name']}';

  /// Durante o voo só o fundo viaja; os textos de cada ponta aparecem depois.
  static Widget flightShuttle(
    BuildContext context,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext from,
    BuildContext to,
    String name,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: ProjectCoverBackdrop(name: name, scale: 200),
    );
  }

  @override
  State<ProjectCover> createState() => _ProjectCoverState();
}

/// Gradiente, ondas e monograma: o "material" da capa, sem textos.
class ProjectCoverBackdrop extends StatelessWidget {
  final String name;
  final double scale;

  const ProjectCoverBackdrop({
    super.key,
    required this.name,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final h = scale;
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: ProjectCover.colorsFor(name),
            ),
          ),
        ),
        CustomPaint(painter: _RipplePainter()),
        Positioned(
          right: -h * 0.06,
          bottom: -h * 0.28,
          child: Text(
            name.isEmpty ? '' : name.characters.first.toUpperCase(),
            style: AppFonts.poppins(
              textStyle: TextStyle(
                fontSize: h * 1.1,
                height: 1,
                fontWeight: FontWeight.w800,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectCoverState extends State<ProjectCover> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final name = '${p['name'] ?? ''}';
    final platform = '${p['platform'] ?? ''}';
    final state = '${p['state'] ?? ''}';
    final techs = (p['technologiesUsed'] as List?)?.map((e) => '$e').toList() ??
        const <String>[];
    final h = widget.scale;

    return Hero(
      tag: ProjectCover.heroTag(p),
      flightShuttleBuilder: (context, animation, direction, from, to) =>
          ProjectCover.flightShuttle(
        context,
        animation,
        direction,
        from,
        to,
        name,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(h * 0.07),
            boxShadow: const [
              BoxShadow(
                color: Color(0x47000000),
                blurRadius: 40,
                spreadRadius: -14,
                offset: Offset(0, 22),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(h * 0.07),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ProjectCoverBackdrop(name: name, scale: h),
                Padding(
                  padding: EdgeInsets.all(h * 0.08),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              platform.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: math.max(10.5, h * 0.05),
                                fontWeight: FontWeight.w700,
                                letterSpacing: h * 0.008,
                              ),
                            ),
                          ),
                          if (state.isNotEmpty) _Pill(text: state, scale: h),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.poppins(
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: h * 0.13,
                            height: 1.05,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      SizedBox(height: h * 0.06),
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: h * 0.02,
                              runSpacing: h * 0.02,
                              clipBehavior: Clip.hardEdge,
                              children: [
                                for (final t in techs.take(3))
                                  _Pill(text: t, scale: h),
                              ],
                            ),
                          ),
                          if (widget.front)
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 180),
                              opacity: _hover ? 1 : 0.8,
                              child: _Pill(
                                text: 'Ver detalhes ↗',
                                scale: h,
                                strong: true,
                              ),
                            ),
                        ],
                      ),
                    ],
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

class _Pill extends StatelessWidget {
  final String text;
  final double scale;
  final bool strong;

  const _Pill({required this.text, required this.scale, this.strong = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scale * 0.04,
        vertical: scale * 0.018,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: strong ? 0.9 : 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: strong ? 0 : 0.18),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: strong ? const Color(0xFF0F172A) : Colors.white,
          fontSize: math.max(11, scale * 0.05),
          fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

/// Ondas concêntricas no canto superior direito, como um pingo na água.
class _RipplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.86, size.height * 0.08);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 1; i <= 6; i++) {
      paint.color = Colors.white.withValues(alpha: 0.11 - i * 0.014);
      canvas.drawCircle(center, size.height * 0.16 * i, paint);
    }
  }

  @override
  bool shouldRepaint(_RipplePainter old) => false;
}
