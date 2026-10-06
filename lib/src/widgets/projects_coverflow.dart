import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:portfolio/src/utils/app_fonts.dart';
import 'package:portfolio/src/utils/colors.dart';
import 'package:portfolio/src/widgets/project_cover.dart';
import 'package:portfolio/src/widgets/projects.dart';

// Coverflow: o card do centro fica de frente; os vizinhos recuam e giram em
// Y, cada vez menos conforme se afastam, para continuarem legíveis.
//
// Uma posição fracionária (`pos`) é a única fonte de verdade. O loop não
// clona cards: a distância de cada um é dobrada para o caminho mais curto
// ao redor do anel.

const _rotate = 44.0; // graus que o primeiro vizinho inclina
const _depth = 0.6; // quanto o primeiro vizinho recua, em larguras de card
const _perspective = 3.0; // distância do observador, em larguras de card
const _falloff = 0.56; // expoente na distância: <1 suaviza o giro ao afastar
const _fade = 0.1; // opacidade perdida por passo a partir do centro
const _gap = 0.05; // espaço entre cards, em larguras de card
const _ease = 0.16; // fração da distância restante percorrida por frame
const _shadowPad = 40.0; // folga vertical para as sombras não serem cortadas

class ProjectsCoverflow extends StatefulWidget {
  final List<Map<String, dynamic>> projects;
  final BoxConstraints constraints;
  final bool loop;

  const ProjectsCoverflow({
    super.key,
    required this.projects,
    required this.constraints,
    this.loop = true,
  });

  @override
  State<ProjectsCoverflow> createState() => _ProjectsCoverflowState();
}

class _ProjectsCoverflowState extends State<ProjectsCoverflow>
    with SingleTickerProviderStateMixin {
  final _pos = ValueNotifier<double>(0);
  final _selected = ValueNotifier<int>(0);
  final _focus = FocusNode(debugLabel: 'ProjectsCoverflow');
  late final Ticker _ticker = createTicker(_onTick);

  /// Para onde o assentamento atual vai. Avançar a partir dele, e não de
  /// `pos`, evita engolir uma tecla apertada no meio da animação.
  double _target = 0;
  double _dragStartPos = 0;
  double _dragDx = 0;
  bool _reduced = false;
  Timer? _settling;

  int get _count => widget.projects.length;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.disableAnimationsOf(context);
  }

  @override
  void dispose() {
    _settling?.cancel();
    _ticker.dispose();
    _pos.dispose();
    _selected.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Card inteiro mais próximo, dobrado de volta para 0..count-1.
  int _indexAt(double pos) => ((pos.round() % _count) + _count) % _count;

  double _clamp(double pos) =>
      widget.loop ? pos : pos.clamp(0.0, (_count - 1).toDouble());

  void _settle(double target) {
    _target = target;
    _selected.value = _indexAt(target);
    if (_reduced) {
      _pos.value = target;
      _ticker.stop();
      return;
    }
    if (!_ticker.isActive) _ticker.start();
  }

  void _onTick(Duration _) {
    final remaining = _target - _pos.value;
    if (remaining.abs() < 0.0004) {
      _pos.value = _target;
      _ticker.stop();
    } else {
      _pos.value += remaining * _ease;
    }
  }

  void _goTo(int index) {
    // Pelo caminho mais curto, em vez de desenrolar o anel inteiro.
    final target = widget.loop
        ? index + ((_target - index) / _count).round() * _count
        : index;
    _settle(_clamp(target.toDouble()));
  }

  void _nudge(int by) => _settle(_clamp(_target.roundToDouble() + by));

  void _onTap(int index) {
    if (_indexAt(_pos.value) == index) {
      DetailsWidget.details(
        context,
        constraints: widget.constraints,
        project: widget.projects[index],
      );
    } else {
      _goTo(index);
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowLeft) {
      _nudge(-1);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _nudge(1);
    } else if (key == LogicalKeyboardKey.enter) {
      _onTap(_selected.value);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  // Rolagem horizontal do trackpad (ou shift + rodinha) passa os cards; a
  // vertical continua rolando a página.
  void _onPointerSignal(PointerSignalEvent event, double pitch) {
    if (event is! PointerScrollEvent) return;
    final dx = event.scrollDelta.dx;
    if (dx.abs() <= event.scrollDelta.dy.abs()) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      _settle(_clamp(_target + dx / pitch));
      // O gesto do trackpad não tem fim próprio: assenta num card depois de
      // um instante sem eventos.
      _settling?.cancel();
      _settling = Timer(
        const Duration(milliseconds: 140),
        () => _settle(_clamp(_target.roundToDouble())),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final portrait = screen.height > screen.width;
    final side = portrait
        ? math.min(screen.width * 0.64, 320.0)
        : (screen.width * 0.24).clamp(240.0, 330.0);
    final pitch = side * (1 + _gap);

    return Semantics(
      label: 'Carrossel de projetos',
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Focus(
                focusNode: _focus,
                onKeyEvent: _onKey,
                child: Listener(
                  onPointerDown: (_) => _focus.requestFocus(),
                  onPointerSignal: (e) => _onPointerSignal(e, pitch),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    // Arraste horizontal é do carrossel; o vertical segue
                    // rolando a página.
                    onHorizontalDragStart: (_) {
                      _ticker.stop();
                      _dragStartPos = _pos.value;
                      _dragDx = 0;
                    },
                    onHorizontalDragUpdate: (d) {
                      _dragDx += d.delta.dx;
                      _pos.value = _clamp(_dragStartPos - _dragDx / pitch);
                      _target = _pos.value;
                      _selected.value = _indexAt(_pos.value);
                    },
                    onHorizontalDragEnd: (d) {
                      // Cards por segundo; um peteleco leva no máximo dois.
                      final v = -d.velocity.pixelsPerSecond.dx / pitch;
                      final carried = (v * 0.18).clamp(-2.0, 2.0);
                      _settle(_clamp((_pos.value + carried).roundToDouble()));
                    },
                    child: ClipRect(
                      child: SizedBox(
                        height: side + _shadowPad * 2,
                        width: double.infinity,
                        child: ValueListenableBuilder<int>(
                          valueListenable: _selected,
                          builder: (context, selected, _) => Flow(
                            delegate: _CoverflowDelegate(
                              pos: _pos,
                              side: side,
                              count: _count,
                              loop: widget.loop,
                            ),
                            children: [
                              for (var i = 0; i < _count; i++)
                                GestureDetector(
                                  onTap: () => _onTap(i),
                                  child: ProjectCover(
                                    project: widget.projects[i],
                                    scale: side * 0.66,
                                    front: i == selected,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (!portrait) ...[
                Positioned(
                  left: 12,
                  child: _NavButton(
                    tooltip: 'Projeto anterior',
                    icon: Icons.chevron_left_rounded,
                    onPressed: () => _nudge(-1),
                  ),
                ),
                Positioned(
                  right: 12,
                  child: _NavButton(
                    tooltip: 'Próximo projeto',
                    icon: Icons.chevron_right_rounded,
                    onPressed: () => _nudge(1),
                  ),
                ),
              ],
            ],
          ),
          ValueListenableBuilder<int>(
            valueListenable: _selected,
            builder: (context, selected, _) => Column(
              children: [
                _Caption(project: widget.projects[selected]),
                const SizedBox(height: 20),
                _Pagination(
                  count: _count,
                  selected: selected,
                  onSelect: _goTo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

double _rad(double deg) => deg * math.pi / 180;

class _CoverflowDelegate extends FlowDelegate {
  final ValueNotifier<double> pos;
  final double side;
  final int count;
  final bool loop;

  _CoverflowDelegate({
    required this.pos,
    required this.side,
    required this.count,
    required this.loop,
  }) : super(repaint: pos);

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) =>
      BoxConstraints.tight(Size.square(side));

  double _offset(int index) {
    var offset = index - pos.value;
    if (loop) {
      // Dobra a distância para o lado mais curto do anel. É todo o mecanismo
      // de loop: sem clones, sem reordenar a árvore.
      offset = ((offset % count) + count) % count;
      if (offset > count / 2) offset -= count;
    }
    return offset;
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final pitch = side * (1 + _gap);
    final center = context.size.center(Offset.zero);
    final perspective = Matrix4.identity()
      ..setEntry(3, 2, -1 / (side * _perspective));

    // Do mais distante ao mais próximo: a ordem de pintura é o z-index.
    final order = List.generate(count, (i) => i)
      ..sort((a, b) => _offset(b).abs().compareTo(_offset(a).abs()));

    for (final i in order) {
      final offset = _offset(i);
      final distance = offset.abs();
      // Inclinação e recuo crescem cada vez menos com a distância; uma rampa
      // linear fecharia o segundo card de lado.
      final ramp = math.pow(distance, _falloff).toDouble();
      // Limitado antes de ficar de perfil, para nenhum card virar de costas.
      final tilt = math.min(_rotate * ramp, 82) * offset.sign;

      // Um card atravessa o anel exatamente a meia volta; precisa ter sumido
      // antes disso, ou o salto aparece.
      final edge = loop ? (count / 2 - distance).clamp(0.0, 1.0) : 1.0;
      final opacity = math.max(0.0, 1 - _fade * distance) * edge;
      if (opacity <= 0.01) continue;

      final transform = Matrix4.translationValues(center.dx, center.dy, 0)
        ..multiply(perspective)
        ..translateByDouble(offset * pitch, 0, -_depth * side * ramp, 1)
        ..rotateY(_rad(-tilt))
        ..translateByDouble(-side / 2, -side / 2, 0, 1);

      context.paintChild(i, transform: transform, opacity: opacity);
    }
  }

  @override
  bool shouldRepaint(_CoverflowDelegate old) =>
      old.pos != pos ||
      old.side != side ||
      old.count != count ||
      old.loop != loop;

  @override
  bool shouldRelayout(_CoverflowDelegate old) => old.side != side;
}

class _NavButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _NavButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
        backgroundColor: ColorsApp.surface(context).withValues(alpha: 0.75),
        foregroundColor: ColorsApp.letters(context),
        side: BorderSide(color: ColorsApp.border(context)),
      ),
      icon: Icon(icon, size: 24),
    );
  }
}

/// Legenda do projeto em foco, com troca suave a cada mudança.
class _Caption extends StatelessWidget {
  final Map<String, dynamic> project;

  const _Caption({required this.project});

  @override
  Widget build(BuildContext context) {
    final techs = (project['technologiesUsed'] as List?)?.join(' · ') ?? '';
    final meta = [
      ('Plataforma', '${project['platform'] ?? ''}'),
      ('Status', '${project['state'] ?? ''}'),
      ('Minha função', '${project['myFunction'] ?? ''}'),
      ('Tecnologias', techs),
    ].where((row) => row.$2.isNotEmpty);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Padding(
        key: ValueKey(project['name']),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            children: [
              Text(
                '${project['name'] ?? ''}',
                textAlign: TextAlign.center,
                style: AppFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: ColorsApp.letters(context),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${project['description'] ?? ''}',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: ColorsApp.muted(context)),
              ),
              const SizedBox(height: 20),
              for (final (label, value) in meta)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorsApp.muted(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          value,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ColorsApp.letters(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  final int count;
  final int selected;
  final ValueChanged<int> onSelect;

  const _Pagination({
    required this.count,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Semantics(
            button: true,
            selected: i == selected,
            label: 'Ir para o projeto ${i + 1}',
            child: InkResponse(
              onTap: () => onSelect(i),
              radius: 16,
              // Área de toque de 32px para um ponto de 8px.
              child: SizedBox.square(
                dimension: 32,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: i == selected ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: ColorsApp.letters(context)
                          .withValues(alpha: i == selected ? 1 : 0.3),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
