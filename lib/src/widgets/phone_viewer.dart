import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:portfolio/src/utils/colors.dart';
import 'package:portfolio/src/widgets/droplets/water_droplet_field.dart';

class PhoneViewer extends StatefulWidget {
  final BoxConstraints constraints;

  static const assetPath = 'assets/models/phone.glb';

  const PhoneViewer({super.key, required this.constraints});

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
    final height =
        isDesktop ? (size.height * 0.92).clamp(740.0, 1120.0) : 600.0;

    return Semantics(
      label: 'Visualização 3D de um celular. Arraste para orbitar.',
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
              return WaterDropletField(
                child: ModelViewer(
                  src: PhoneViewer.viewerSrc,
                  alt: 'Modelo 3D interativo de um celular',
                  autoRotate: true,
                  autoPlay: true,
                  cameraControls: true,
                  disableZoom: true,
                  disablePan: true,
                  debugLogging: false,
                  loading: Loading.eager,
                  cameraOrbit: '18deg 78deg 105%',
                  fieldOfView: '18deg',
                  minCameraOrbit: 'auto auto 105%',
                  maxCameraOrbit: 'auto auto 105%',
                  backgroundColor: Colors.transparent,
                  relatedCss:
                      'html,body{margin:0;padding:0;background:transparent;overflow:hidden}'
                      'model-viewer{outline:none;border:none;background:transparent}',
                ),
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
