import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:portfolio/src/utils/colors.dart';
import 'package:portfolio/src/utils/viewport_visibility.dart';
import 'package:portfolio/src/widgets/droplets/model_viewer_dom.dart';
import 'package:portfolio/src/widgets/droplets/water_droplet_field.dart';

/// Logo de uma tecnologia para os selos que flutuam ao redor do celular.
typedef TechBadge = ({String title, Uint8List image});

class PhoneViewer extends StatefulWidget {
  final BoxConstraints constraints;
  final List<TechBadge> badges;

  static const assetPath = 'assets/models/phone.glb';

  const PhoneViewer({
    super.key,
    required this.constraints,
    this.badges = const [],
  });

  static String get viewerSrc {
    if (kIsWeb) {
      return 'assets/$assetPath';
    }
    return assetPath;
  }

  @override
  State<PhoneViewer> createState() => _PhoneViewerState();
}

class _PhoneViewerState extends State<PhoneViewer> {
  late final Future<bool> _hasGlb = _loadGlb();
  bool _orbited = false;

  /// Fixo (padrão): gira sozinho e ignora o arraste. Móvel: segue o dedo.
  bool _interactive = false;

  /// Fora do web não dá para mexer no elemento: o modelo é recriado.
  int _nativeRebuild = 0;

  void _setInteractive(bool interactive, String initialOrbit) {
    if (interactive == _interactive) return;
    setState(() => _interactive = interactive);
    // Ao voltar para o fixo, a câmera retorna ao ângulo inicial (horizontal).
    final applied = setModelViewerInteractive(
      interactive,
      resetOrbit: interactive ? null : initialOrbit,
    );
    if (!applied) setState(() => _nativeRebuild++);
  }

  Future<bool> _loadGlb() async {
    try {
      await rootBundle.load(PhoneViewer.assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDesktop = widget.constraints.maxWidth > 980;
    final width = isDesktop
        ? (size.width * 0.52).clamp(520.0, 860.0)
        : (widget.constraints.maxWidth * 0.96).clamp(320.0, 640.0);
    final height = isDesktop
        ? (size.height * 0.92).clamp(740.0, 1120.0)
        : (size.height * 0.62).clamp(440.0, 560.0);
    final initialOrbit = isDesktop ? '18deg 78deg 105%' : '18deg 78deg auto';

    return Semantics(
      label: _interactive
          ? 'Visualização 3D de um celular. Arraste para girar.'
          : 'Visualização 3D de um celular girando.',
      child: SizedBox(
        width: width,
        height: height,
        child: FutureBuilder<bool>(
          future: _hasGlb,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(
                  color: ColorsApp.accent(context),
                ),
              );
            }
            if (snapshot.data == true) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  WaterDropletField(
                    followDrag: _interactive,
                    onUserOrbit: () => setState(() => _orbited = true),
                    child: ModelViewer(
                      key: ValueKey(_nativeRebuild),
                      src: PhoneViewer.viewerSrc,
                      alt: 'Modelo 3D interativo de um celular',
                      autoRotate: true,
                      autoPlay: true,
                      cameraControls: _interactive,
                      disableZoom: true,
                      disablePan: true,
                      debugLogging: false,
                      loading: Loading.eager,
                      // No desktop o enquadramento é fixo e fechado. Em telas
                      // estreitas o campo de visão fixo cortava o aparelho;
                      // lá o model-viewer enquadra sozinho ("auto").
                      cameraOrbit: initialOrbit,
                      fieldOfView: isDesktop ? '18deg' : null,
                      minCameraOrbit: isDesktop ? 'auto auto 105%' : null,
                      maxCameraOrbit: isDesktop ? 'auto auto 105%' : null,
                      backgroundColor: Colors.transparent,
                      relatedCss:
                          'html,body{margin:0;padding:0;background:transparent;overflow:hidden}'
                          'model-viewer{outline:none;border:none;background:transparent}',
                    ),
                  ),
                  if (widget.badges.isNotEmpty)
                    _FloatingBadges(
                      badges: widget.badges,
                      compact: !isDesktop,
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: isDesktop ? 40 : 10,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _RotateHint(visible: _interactive && !_orbited),
                        const SizedBox(height: 10),
                        _ModeToggle(
                          interactive: _interactive,
                          onChanged: (v) => _setInteractive(v, initialOrbit),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const InteractivePhoneFallback();
          },
        ),
      ),
    );
  }
}

class InteractivePhoneFallback extends StatefulWidget {
  const InteractivePhoneFallback({super.key});

  @override
  State<InteractivePhoneFallback> createState() =>
      _InteractivePhoneFallbackState();
}

class _InteractivePhoneFallbackState extends State<InteractivePhoneFallback> {
  double _rx = 0.18;
  double _ry = -0.35;

  void _tilt(Offset local, Size size) {
    if (size.width == 0 || size.height == 0) return;
    final nx = ((local.dx / size.width) - 0.5) * 2;
    final ny = ((local.dy / size.height) - 0.5) * 2;
    setState(() {
      _ry = nx * 0.55;
      _rx = -ny * 0.4;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = ColorsApp.accent(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return MouseRegion(
                onHover: reduceMotion
                    ? null
                    : (event) =>
                        _tilt(event.localPosition, constraints.biggest),
                child: GestureDetector(
                  onPanUpdate: reduceMotion
                      ? null
                      : (details) {
                          setState(() {
                            _ry += details.delta.dx * 0.008;
                            _rx -= details.delta.dy * 0.008;
                            _rx = _rx.clamp(-0.7, 0.7);
                            _ry = _ry.clamp(-0.9, 0.9);
                          });
                        },
                  child: Center(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0014)
                        ..rotateX(_rx)
                        ..rotateY(_ry),
                      child: _PhoneBody(accent: accent),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Arraste para orbitar · modelo 3D indisponível',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ColorsApp.muted(context),
            fontSize: 12,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _OrbitButton(
              label: 'Girar esquerda',
              icon: Icons.rotate_left,
              onPressed: () => setState(() => _ry -= 0.25),
            ),
            _OrbitButton(
              label: 'Girar direita',
              icon: Icons.rotate_right,
              onPressed: () => setState(() => _ry += 0.25),
            ),
          ],
        ),
      ],
    );
  }
}

class _OrbitButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _OrbitButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      tooltip: label,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
        side: BorderSide(color: ColorsApp.border(context)),
        foregroundColor: ColorsApp.letters(context),
      ),
      icon: Icon(icon, size: 20),
    );
  }
}

class _PhoneBody extends StatelessWidget {
  final Color accent;

  const _PhoneBody({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      height: 420,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(42),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
            Color(0xFF020617),
          ],
        ),
        border: Border.all(color: const Color(0xFF475569), width: 3),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.28),
            blurRadius: 40,
            spreadRadius: 2,
            offset: const Offset(12, 24),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1220), Color(0xFF111827)],
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 72,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF020617),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.smartphone, color: accent, size: 42),
                  const SizedBox(height: 12),
                  Text(
                    'GLB',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'aguardando modelo',
                    style: TextStyle(
                      color: ColorsApp.mutedDark,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Selos com logos das tecnologias flutuando ao redor do celular: um atalho
/// visual para quem chega entender de cara com o que eu trabalho.
class _FloatingBadges extends StatefulWidget {
  final List<TechBadge> badges;
  final bool compact;

  const _FloatingBadges({required this.badges, required this.compact});

  @override
  State<_FloatingBadges> createState() => _FloatingBadgesState();
}

class _FloatingBadgesState extends State<_FloatingBadges>
    with SingleTickerProviderStateMixin, ViewportVisibility {
  late final _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  // Cantos ao redor do aparelho, fora da silhueta dele.
  static const _spots = [
    Alignment(-0.82, -0.62),
    Alignment(0.80, -0.74),
    Alignment(-0.88, 0.38),
    Alignment(0.86, 0.26),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void onViewportVisibilityChanged(bool visible) => _sync();

  // Flutua só com o celular na tela e sem "reduzir movimento".
  void _sync() {
    final animate =
        visibleInViewport && !MediaQuery.disableAnimationsOf(context);
    if (animate && !_float.isAnimating) {
      _float.repeat();
    } else if (!animate && _float.isAnimating) {
      _float.stop();
    }
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.compact ? 46.0 : 60.0;
    final badges = widget.badges.take(_spots.length).toList();

    return IgnorePointer(
      child: RepaintBoundary(
        child: Stack(
          children: [
            for (var i = 0; i < badges.length; i++)
              Align(
                alignment: _spots[i],
                child: AnimatedBuilder(
                  animation: _float,
                  builder: (context, child) {
                    final t = (_float.value + i * 0.27) * 2 * math.pi;
                    return Transform.translate(
                      offset: Offset(0, math.sin(t) * 7),
                      child: Transform.rotate(
                        angle: math.sin(t + 1) * 0.06,
                        child: child,
                      ),
                    );
                  },
                  child: Semantics(
                    label: badges[i].title,
                    child: Container(
                      width: size,
                      height: size,
                      padding: EdgeInsets.all(size * 0.2),
                      decoration: BoxDecoration(
                        color:
                            ColorsApp.surface(context).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(size * 0.3),
                        border: Border.all(color: ColorsApp.border(context)),
                        boxShadow: [
                          BoxShadow(
                            color: ColorsApp.shadowColor(context),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Image.memory(
                        badges[i].image,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                        cacheWidth: (size * 2).round(),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// "Arraste para girar": some depois do primeiro giro. No toque não havia
/// nenhum sinal de que o modelo é interativo.
class _RotateHint extends StatelessWidget {
  final bool visible;

  const _RotateHint({required this.visible});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 400),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: ColorsApp.surface(context).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: ColorsApp.border(context)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.swipe_rounded,
                  size: 18,
                  color: ColorsApp.accent(context),
                ),
                const SizedBox(width: 8),
                Text(
                  'Arraste para girar',
                  style: TextStyle(
                    color: ColorsApp.letters(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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

/// Alterna entre "Fixo" (gira sozinho, ignora o arraste) e "Móvel" (segue o
/// arraste). No fixo a rolagem da página por cima do modelo também fica livre.
class _ModeToggle extends StatelessWidget {
  final bool interactive;
  final ValueChanged<bool> onChanged;

  const _ModeToggle({required this.interactive, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: ColorsApp.surface(context).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: ColorsApp.border(context)),
          boxShadow: [
            BoxShadow(
              color: ColorsApp.shadowColor(context),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModeOption(
              icon: Icons.threesixty_rounded,
              label: 'Fixo',
              tooltip: 'Gira sozinho',
              selected: !interactive,
              onTap: () => onChanged(false),
            ),
            _ModeOption(
              icon: Icons.pan_tool_alt_outlined,
              label: 'Móvel',
              tooltip: 'Arraste para girar',
              selected: interactive,
              onTap: () => onChanged(true),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;

  const _ModeOption({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg =
        selected ? ColorsApp.onAccent(context) : ColorsApp.letters(context);
    return Semantics(
      button: true,
      selected: selected,
      label: '$label: $tooltip',
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(99),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(minHeight: 40, minWidth: 44),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: selected ? ColorsApp.accent(context) : Colors.transparent,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 17, color: fg),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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
