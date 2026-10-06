import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:portfolio/src/utils/app_fonts.dart';
import 'package:portfolio/src/utils/app_images.dart';
import 'package:portfolio/src/widgets/decision_lab/decision_lab.dart';
import 'package:portfolio/src/widgets/section_heading.dart';
import '../utils/colors.dart';

// Lista de habilidades no estilo "rolling list": cada linha é um título
// enorme que, no hover, rola para uma cópia em itálico na cor de destaque,
// enquanto o logo da tecnologia surge girando e ganhando cor. Clicar abre a
// descrição — e no toque, sem hover, é o clique que ativa o efeito.

/// A curva do original: `cubic-bezier(0.76, 0, 0.24, 1)`.
const _rollCurve = Cubic(0.76, 0, 0.24, 1);
const _rollDuration = Duration(milliseconds: 500);

class Attributes extends StatefulWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;
  final GlobalKey attributeKey;

  const Attributes({
    super.key,
    required this.constraints,
    required this.data,
    required this.attributeKey,
  });

  @override
  State<Attributes> createState() => _AttributesState();
}

class _AttributesState extends State<Attributes> {
  List<Uint8List> _images = [];
  bool _imagesReady = false;
  int? _expanded;

  List<Map> get _attributes =>
      List<Map>.from(widget.data["attributes"] as List? ?? const []);

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final attributes = _attributes;
    List<Uint8List> decoded = [];
    try {
      if (attributes.isNotEmpty && attributes.first["image"] is Uint8List) {
        decoded = [for (final a in attributes) a["image"] as Uint8List];
      } else if (attributes.isNotEmpty) {
        decoded = await decodeBase64Images(
          [for (final a in attributes) '${a["image"] ?? ''}'],
        );
      }
    } catch (_) {
      // Sem logos a lista continua funcionando; só não há o reveal.
    }
    if (!mounted) return;
    setState(() {
      _images = decoded;
      _imagesReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final attributes = _attributes;
    final width = widget.constraints.maxWidth;
    // Lista e laboratório lado a lado só quando os dois cabem com folga.
    final split = width > 1100;
    final horizontal = width > 1050
        ? 88.0
        : width > 480
            ? 40.0
            : 20.0;

    final Widget list;
    if (!_imagesReady) {
      list = Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: CircularProgressIndicator(color: ColorsApp.accent(context)),
        ),
      );
    } else if (attributes.isEmpty) {
      list = Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Text(
          "Não há habilidades",
          style: AppFonts.aBeeZee(
            fontSize: width > 480 ? 18 : 16,
            color: ColorsApp.letters(context),
          ),
        ),
      );
    } else {
      list = LayoutBuilder(
        builder: (context, box) {
          // O reveal do logo precisa de espaço à direita do título.
          final rowsWide = box.maxWidth >= 480;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SideLabel('STACK  ·  PASSE O MOUSE OU TOQUE'),
              const SizedBox(height: 16),
              Divider(height: 1, color: ColorsApp.border(context)),
              for (var i = 0; i < attributes.length; i++)
                _RollingSkill(
                  attribute: attributes[i],
                  logo: i < _images.length ? _images[i] : null,
                  wide: rowsWide,
                  expanded: _expanded == i,
                  onToggle: () => setState(
                    () => _expanded = _expanded == i ? null : i,
                  ),
                ),
            ],
          );
        },
      );
    }

    const lab = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SideLabel('LABORATÓRIO  ·  MOTOR DE DECISÃO'),
        SizedBox(height: 16),
        DecisionLab(),
      ],
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal, 40, horizontal, 0),
      child: Column(
        children: [
          TitleAtributtes(constraints: widget.constraints),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: split ? 1240 : 620),
            child: split
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: list),
                      const SizedBox(width: 56),
                      const Expanded(flex: 6, child: lab),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [list, const SizedBox(height: 64), lab],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SideLabel extends StatelessWidget {
  final String text;

  const _SideLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: ColorsApp.accent(context),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.4,
      ),
    );
  }
}

String _levelLabel(double level) {
  if (level >= 4.5) return 'Especialista';
  if (level >= 3.5) return 'Avançado';
  if (level >= 2.5) return 'Intermediário';
  return 'Básico';
}

class _RollingSkill extends StatefulWidget {
  final Map attribute;
  final Uint8List? logo;
  final bool wide;
  final bool expanded;
  final VoidCallback onToggle;

  const _RollingSkill({
    required this.attribute,
    required this.logo,
    required this.wide,
    required this.expanded,
    required this.onToggle,
  });

  @override
  State<_RollingSkill> createState() => _RollingSkillState();
}

class _RollingSkillState extends State<_RollingSkill> {
  bool _hover = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final title = '${widget.attribute['title'] ?? ''}';
    final level = ((widget.attribute['level'] ?? 0) as num).toDouble();
    final description = '${widget.attribute['description'] ?? ''}';
    final points = [
      // Ponto seguido de espaço ou fim do texto: "Next.js" não vira dois tópicos.
      for (final p in description.split(RegExp(r'\.(?=\s|$)')))
        if (p.trim().isNotEmpty) p.trim(),
    ];
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : _rollDuration;
    final active = _hover || _focused || widget.expanded;
    final lineH = widget.wide ? 56.0 : 44.0;
    final fontSize = widget.wide ? 44.0 : 32.0;

    return Semantics(
      button: true,
      expanded: widget.expanded,
      label: '$title, nível ${_levelLabel(level)}',
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowHoverHighlight: (v) => setState(() => _hover = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onToggle();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onToggle,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: ColorsApp.border(context)),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: lineH,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          right: widget.wide ? 170 : 0,
                          child: _RollingTitle(
                            text: title,
                            lineHeight: lineH,
                            fontSize: fontSize,
                            active: active,
                            duration: duration,
                          ),
                        ),
                        if (widget.wide)
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: AnimatedOpacity(
                              opacity: active ? 0 : 1,
                              duration: duration * 0.6,
                              child: _LevelLabel(level: level),
                            ),
                          ),
                        if (widget.wide && widget.logo != null)
                          Positioned(
                            right: 0,
                            top: lineH / 2 - 50,
                            child: _LogoReveal(
                              logo: widget.logo!,
                              visible: active,
                              duration: duration,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!widget.wide) ...[
                    const SizedBox(height: 8),
                    _LevelLabel(level: level),
                  ],
                  AnimatedSize(
                    duration: duration,
                    curve: _rollCurve,
                    alignment: Alignment.topCenter,
                    child: widget.expanded
                        ? _Details(
                            points: points,
                            level: level,
                            logo: widget.wide ? null : widget.logo,
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Duas cópias empilhadas numa janela da altura de uma linha; o hover
/// desliza a pilha para cima e revela a segunda.
class _RollingTitle extends StatelessWidget {
  final String text;
  final double lineHeight;
  final double fontSize;
  final bool active;
  final Duration duration;

  const _RollingTitle({
    required this.text,
    required this.lineHeight,
    required this.fontSize,
    required this.active,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    Widget line(Color color, {bool italic = false}) => SizedBox(
          height: lineHeight,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                text.toUpperCase(),
                maxLines: 1,
                style: AppFonts.aBeeZee(
                  textStyle: TextStyle(
                    fontSize: fontSize,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -fontSize * 0.03,
                    color: color,
                    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
            ),
          ),
        );

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.topLeft,
        maxHeight: lineHeight * 2,
        child: AnimatedSlide(
          offset: Offset(0, active ? -0.5 : 0),
          duration: duration,
          curve: _rollCurve,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              line(ColorsApp.letters(context)),
              line(ColorsApp.accent(context), italic: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelLabel extends StatelessWidget {
  final double level;

  const _LevelLabel({required this.level});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _levelLabel(level).toUpperCase(),
          style: TextStyle(
            color: ColorsApp.muted(context),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.4,
          ),
        ),
        const SizedBox(width: 12),
        _LevelDots(level: level),
      ],
    );
  }
}

class _LevelDots extends StatelessWidget {
  final double level;

  const _LevelDots({required this.level});

  static const size = 6.0;

  @override
  Widget build(BuildContext context) {
    final accent = ColorsApp.accent(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Container(
            width: size,
            height: size,
            margin: EdgeInsets.only(left: i == 0 ? 0 : size * 0.6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: level >= i + 0.75
                  ? accent
                  : level >= i + 0.25
                      ? accent.withValues(alpha: 0.5)
                      : ColorsApp.border(context),
            ),
          ),
      ],
    );
  }
}

const _grayscale = ColorFilter.matrix([
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
]);

/// O cartão com o logo: entra girando de leve, crescendo e ganhando cor.
class _LogoReveal extends StatelessWidget {
  final Uint8List logo;
  final bool visible;
  final Duration duration;

  const _LogoReveal({
    required this.logo,
    required this.visible,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final accent = ColorsApp.accent(context);
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: visible ? 1 : 0),
        duration: duration,
        curve: Curves.easeOut,
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translateByDouble(16 * (1 - t), 0, 0, 1)
              ..rotateZ(0.052 * (1 - t)) // 3°
              ..scaleByDouble(0.95 + 0.05 * t, 0.95 + 0.05 * t, 1, 1),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                child!,
                // Mesmo truque do original: começa cinza e satura.
                Positioned.fill(
                  child: Opacity(
                    opacity: 1 - t,
                    child: ColorFiltered(colorFilter: _grayscale, child: child),
                  ),
                ),
              ],
            ),
          ),
        ),
        child: Container(
          width: 150,
          height: 100,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: ColorsApp.surface(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 40,
                offset: Offset(0, 18),
              ),
            ],
          ),
          child: AppMemoryImage(bytes: logo, width: 114, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  final List<String> points;
  final double level;
  final Uint8List? logo;

  const _Details({required this.points, required this.level, this.logo});

  @override
  Widget build(BuildContext context) {
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final p in points)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 9, right: 12),
                  decoration: BoxDecoration(
                    color: ColorsApp.accent(context),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    p,
                    style: TextStyle(
                      color: ColorsApp.letters(context),
                      fontSize: 16,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (logo != null) ...[
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorsApp.surface(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ColorsApp.border(context)),
              ),
              child:
                  AppMemoryImage(bytes: logo!, width: 40, fit: BoxFit.contain),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: text,
            ),
          ),
        ],
      ),
    );
  }
}

class TitleAtributtes extends StatelessWidget {
  final BoxConstraints constraints;

  const TitleAtributtes({
    super.key,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return const SectionHeading(
      index: '02',
      eyebrow: 'Habilidades',
      title: 'Habilidades',
      subtitle: 'As ferramentas que uso no dia a dia, e um motor de decisão '
          'rodando ao vivo.',
    );
  }
}
