import 'dart:async';

import 'package:flutter/material.dart';
import 'package:portfolio/src/utils/colors.dart';
import 'package:portfolio/src/utils/viewport_visibility.dart';
import 'package:portfolio/src/widgets/decision_lab/snake_engine.dart';

const _tick = Duration(milliseconds: 140);

const _labels = {
  Move.up: 'CIMA',
  Move.down: 'BAIXO',
  Move.left: 'ESQUERDA',
  Move.right: 'DIREITA',
};

const _chevrons = {
  Move.up: Icons.keyboard_arrow_up_rounded,
  Move.down: Icons.keyboard_arrow_down_rounded,
  Move.left: Icons.keyboard_arrow_left_rounded,
  Move.right: Icons.keyboard_arrow_right_rounded,
};

const _arrows = {
  Move.up: Icons.arrow_upward_rounded,
  Move.down: Icons.arrow_downward_rounded,
  Move.left: Icons.arrow_back_rounded,
  Move.right: Icons.arrow_forward_rounded,
};

/// Demo do motor de decisão: a cobra persegue os pontos pelo melhor caminho
/// e o visitante pode adicionar pontos clicando no quadro.
class DecisionLab extends StatefulWidget {
  const DecisionLab({super.key});

  @override
  State<DecisionLab> createState() => _DecisionLabState();
}

class _DecisionLabState extends State<DecisionLab> with ViewportVisibility {
  final _engine = SnakeEngine();
  final _userFoods = <Cell>{};
  Timer? _timer;
  Timer? _restart;
  Cell? _hover;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_tick, (_) => _step());
  }

  // Fora da tela o jogo pausa: nada de passos nem repinturas invisíveis.
  @override
  void onViewportVisibilityChanged(bool visible) {
    _timer?.cancel();
    _timer = visible ? Timer.periodic(_tick, (_) => _step()) : null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restart?.cancel();
    super.dispose();
  }

  void _step() {
    if (_restart != null) return;
    setState(() {
      _engine.step();
      _userFoods.retainAll(_engine.foods);
    });
    if (_engine.gameOver || _engine.crowded) {
      _restart = Timer(const Duration(milliseconds: 1800), _reset);
    }
  }

  void _reset() {
    _restart?.cancel();
    _restart = null;
    setState(() {
      _engine.reset();
      _userFoods.clear();
    });
  }

  void _addFood(Cell c) {
    if (_engine.addFood(c)) setState(() => _userFoods.add(c));
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, box) {
          final side = box.maxWidth >= 620;
          final board = _Board(
            engine: _engine,
            userFoods: _userFoods,
            hover: _hover,
            ended: _restart != null,
            onHover: (c) => setState(() => _hover = c),
            onTap: _addFood,
          );
          final panel = _Panel(engine: _engine, compact: !side);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(engine: _engine, onReset: _reset),
              const SizedBox(height: 16),
              if (side)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 230, child: panel),
                    const SizedBox(width: 20),
                    Expanded(child: board),
                  ],
                )
              else ...[
                board,
                const SizedBox(height: 16),
                panel,
              ],
              const SizedBox(height: 14),
              Text(
                'Clique no quadro para adicionar pontos: o motor replaneja a '
                'ordem de coleta e o caminho. A segurança só intervém quando o '
                'melhor movimento levaria a um beco.',
                style: TextStyle(
                  color: ColorsApp.muted(context),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final SnakeEngine engine;
  final VoidCallback onReset;

  const _TopBar({required this.engine, required this.onReset});

  @override
  Widget build(BuildContext context) {
    final status = engine.gameOver
        ? 'SEM SAÍDA'
        : engine.crowded
            ? 'QUADRO CHEIO'
            : engine.intervened
                ? 'SEGURANÇA ASSUMIU'
                : 'MOTOR DECIDINDO';
    final statusColor = engine.gameOver || engine.intervened
        ? ColorsApp.stars(context)
        : ColorsApp.accent(context);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      spacing: 16,
      runSpacing: 10,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'PONTOS',
              style: TextStyle(
                color: ColorsApp.muted(context),
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              engine.score.toString().padLeft(3, '0'),
              style: TextStyle(
                color: ColorsApp.letters(context),
                fontSize: 22,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration:
                  BoxDecoration(color: statusColor, shape: BoxShape.circle),
            ),
            Text(
              status,
              style: TextStyle(
                color: ColorsApp.letters(context),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
              ),
            ),
            const SizedBox(width: 6),
            OutlinedButton.icon(
              onPressed: onReset,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(44, 40),
                foregroundColor: ColorsApp.letters(context),
                side: BorderSide(color: ColorsApp.border(context)),
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reiniciar'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Board extends StatelessWidget {
  final SnakeEngine engine;
  final Set<Cell> userFoods;
  final Cell? hover;
  final bool ended;
  final ValueChanged<Cell?> onHover;
  final ValueChanged<Cell> onTap;

  const _Board({
    required this.engine,
    required this.userFoods,
    required this.hover,
    required this.ended,
    required this.onHover,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: engine.cols / engine.rows,
      child: LayoutBuilder(
        builder: (context, box) {
          final cell = box.maxWidth / engine.cols;
          Cell at(Offset p) => Cell(
                (p.dx / cell).floor().clamp(0, engine.cols - 1),
                (p.dy / cell).floor().clamp(0, engine.rows - 1),
              );

          return Semantics(
            label: 'Quadro do jogo. Toque para adicionar um ponto.',
            child: MouseRegion(
              cursor: SystemMouseCursors.precise,
              onHover: (e) => onHover(at(e.localPosition)),
              onExit: (_) => onHover(null),
              child: GestureDetector(
                onTapUp: (d) => onTap(at(d.localPosition)),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ColorsApp.border(context)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomPaint(
                          painter: _BoardPainter(
                            engine: engine,
                            userFoods: userFoods,
                            hover: hover,
                            grid: ColorsApp.border(context),
                            snake: ColorsApp.letters(context),
                            food: ColorsApp.accent(context),
                            muted: ColorsApp.muted(context),
                          ),
                        ),
                        if (ended)
                          ColoredBox(
                            color: ColorsApp.background(context)
                                .withValues(alpha: 0.7),
                            child: Center(
                              child: Text(
                                engine.gameOver
                                    ? 'Sem saída — reiniciando…'
                                    : 'Quadro cheio — reiniciando…',
                                style: TextStyle(
                                  color: ColorsApp.letters(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  final SnakeEngine engine;
  final Set<Cell> userFoods;
  final Cell? hover;
  final Color grid;
  final Color snake;
  final Color food;
  final Color muted;

  _BoardPainter({
    required this.engine,
    required this.userFoods,
    required this.hover,
    required this.grid,
    required this.snake,
    required this.food,
    required this.muted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / engine.cols;
    Offset center(Cell c) => Offset((c.x + 0.5) * cell, (c.y + 0.5) * cell);

    // Grade discreta.
    final gridPaint = Paint()
      ..color = grid.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (var x = 1; x < engine.cols; x++) {
      canvas.drawLine(
          Offset(x * cell, 0), Offset(x * cell, size.height), gridPaint);
    }
    for (var y = 1; y < engine.rows; y++) {
      canvas.drawLine(
          Offset(0, y * cell), Offset(size.width, y * cell), gridPaint);
    }

    // Caminho planejado por todos os pontos.
    if (engine.route.length > 1) {
      final path = Path()
        ..moveTo(center(engine.route.first).dx, center(engine.route.first).dy);
      for (final c in engine.route.skip(1)) {
        path.lineTo(center(c).dx, center(c).dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = food.withValues(alpha: 0.35)
          ..strokeWidth = cell * 0.14
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Célula sob o mouse: prévia de onde o ponto vai cair.
    final h = hover;
    if (h != null && !engine.snake.contains(h) && !engine.foods.contains(h)) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(h.x * cell, h.y * cell, cell, cell).deflate(2),
          Radius.circular(cell * 0.25),
        ),
        Paint()..color = food.withValues(alpha: 0.15),
      );
    }

    // Pontos, com a ordem de coleta planejada.
    for (final f in engine.foods) {
      final c = center(f);
      canvas.drawCircle(c, cell * 0.28, Paint()..color = food);
      if (userFoods.contains(f)) {
        canvas.drawCircle(
          c,
          cell * 0.42,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = food.withValues(alpha: 0.6),
        );
      }
      final order = engine.plan.indexOf(f);
      if (order >= 0 && engine.foods.length > 1) {
        final tp = TextPainter(
          text: TextSpan(
            text: '${order + 1}',
            style: TextStyle(
              color: muted,
              fontSize: cell * 0.38,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, c + Offset(cell * 0.3, -cell * 0.62));
      }
    }

    // Cobra: cabeça sólida, corpo esmaecendo até a cauda.
    final n = engine.snake.length;
    for (var i = n - 1; i >= 0; i--) {
      final s = engine.snake[i];
      final alpha = i == 0 ? 1.0 : 0.62 - 0.32 * (i / n);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(s.x * cell, s.y * cell, cell, cell).deflate(1.5),
          Radius.circular(cell * 0.22),
        ),
        Paint()..color = snake.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_BoardPainter old) => true;
}

class _Panel extends StatelessWidget {
  final SnakeEngine engine;
  final bool compact;

  const _Panel({required this.engine, required this.compact});

  @override
  Widget build(BuildContext context) {
    final probs = engine.probabilities;
    final top = probs.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    final label = TextStyle(
      color: ColorsApp.muted(context),
      fontSize: 10.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.6,
    );

    final moves = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PRÓXIMO MOVIMENTO', style: label),
        const SizedBox(height: 10),
        for (final m in Move.values)
          _ProbabilityRow(move: m, value: probs[m] ?? 0, top: m == top),
      ],
    );

    final metrics = Column(
      children: [
        _MetricRow(
          label: 'RISCO DE BECO',
          value: engine.deadEndRisk,
          warn: engine.deadEndRisk > 0.5,
        ),
        const SizedBox(height: 10),
        _MetricRow(label: 'PONTOS ALCANÇÁVEIS', value: engine.foodReachable),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsApp.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorsApp.border(context)),
        boxShadow: [
          BoxShadow(
            color: ColorsApp.shadowColor(context),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.memory_rounded,
                  size: 16, color: ColorsApp.letters(context)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'MOTOR  /  DECISÃO AO VIVO',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ColorsApp.letters(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          moves,
          const SizedBox(height: 14),
          metrics,
          const SizedBox(height: 16),
          _Executing(engine: engine),
          if (!compact) ...[
            const SizedBox(height: 16),
            Divider(height: 1, color: ColorsApp.border(context)),
            const SizedBox(height: 14),
            Text('MOVIMENTOS RECENTES', style: label),
            const SizedBox(height: 8),
            for (final log in engine.history.take(4)) _HistoryRow(log: log),
          ],
        ],
      ),
    );
  }
}

class _ProbabilityRow extends StatelessWidget {
  final Move move;
  final double value;
  final bool top;

  const _ProbabilityRow({
    required this.move,
    required this.value,
    required this.top,
  });

  @override
  Widget build(BuildContext context) {
    final strong = ColorsApp.letters(context);
    final weak = ColorsApp.muted(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(_chevrons[move], size: 14, color: top ? strong : weak),
          const SizedBox(width: 4),
          SizedBox(
            width: 66,
            child: Text(
              _labels[move]!,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(
                color: top ? strong : weak,
                fontSize: 10.5,
                fontWeight: top ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            child: _Bar(value: value, color: top ? strong : weak),
          ),
          SizedBox(
            width: 38,
            child: Text(
              '${(value * 100).round()}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: top ? strong : weak,
                fontSize: 11,
                fontWeight: top ? FontWeight.w700 : FontWeight.w400,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final double value;
  final bool warn;

  const _MetricRow({
    required this.label,
    required this.value,
    this.warn = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = warn ? ColorsApp.stars(context) : ColorsApp.letters(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: ColorsApp.muted(context),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Text(
              value.toStringAsFixed(2),
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _Bar(value: value, color: color.withValues(alpha: 0.75)),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final double value;
  final Color color;

  const _Bar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: ColorsApp.border(context).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(99),
      ),
      alignment: Alignment.centerLeft,
      child: AnimatedFractionallySizedBox(
        duration: _tick,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    );
  }
}

class _Executing extends StatelessWidget {
  final SnakeEngine engine;

  const _Executing({required this.engine});

  @override
  Widget build(BuildContext context) {
    final move = engine.executing;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: engine.intervened
              ? ColorsApp.stars(context)
              : ColorsApp.border(context),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: ColorsApp.border(context).withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              move == null ? Icons.pause_rounded : _arrows[move],
              size: 20,
              color: ColorsApp.letters(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXECUTANDO',
                  style: TextStyle(
                    color: ColorsApp.muted(context),
                    fontSize: 10,
                    letterSpacing: 1.4,
                  ),
                ),
                Text(
                  move == null ? '—' : _labels[move]!,
                  style: TextStyle(
                    color: ColorsApp.letters(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  engine.intervened
                      ? 'Segurança vetou o top-1 · evitou beco'
                      : 'Motor top-1 · sem intervenção',
                  style: TextStyle(
                    color: ColorsApp.muted(context),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final MoveLog log;

  const _HistoryRow({required this.log});

  @override
  Widget build(BuildContext context) {
    final muted = ColorsApp.muted(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              '#${log.tick}',
              style: TextStyle(color: muted, fontSize: 11),
            ),
          ),
          Icon(_arrows[log.move], size: 14, color: ColorsApp.letters(context)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _labels[log.move]!,
              style: TextStyle(
                color: ColorsApp.letters(context),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            log.intervened ? 'SEGURANÇA' : 'MOTOR',
            style: TextStyle(
              color: log.intervened ? ColorsApp.stars(context) : muted,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
