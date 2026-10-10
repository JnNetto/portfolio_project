import 'dart:ui' as ui;

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portfolio/src/controllers/home_controller.dart';
import 'package:portfolio/src/utils/app_fonts.dart';
import 'package:portfolio/src/utils/app_images.dart';
import 'package:portfolio/src/utils/colors.dart';
import 'package:portfolio/src/widgets/project_cover.dart';
import 'package:url_launcher/url_launcher.dart';

/// Abre o detalhe do projeto. A capa do carrossel voa até virar o
/// cabeçalho (Hero) enquanto o fundo desfoca e o corpo sobe.
Future<void> showProjectDetails(
  BuildContext context,
  Map<String, dynamic> project,
) {
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: true,
      barrierLabel: 'Fechar detalhes',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 520),
      reverseTransitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (context, animation, _) =>
          ProjectDetailsPage(project: project, animation: animation),
    ),
  );
}

const _wideBreakpoint = 760.0;

class ProjectDetailsPage extends StatefulWidget {
  final Map<String, dynamic> project;
  final Animation<double> animation;

  const ProjectDetailsPage({
    super.key,
    required this.project,
    required this.animation,
  });

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  late Future<List<Uint8List>> _images = _load();
  double _drag = 0;
  bool _dragging = false;

  String get _name => '${widget.project['name'] ?? ''}';

  Future<List<Uint8List>> _load() => HomeController().fetchImages(_name);

  void _close() => Navigator.of(context).maybePop();

  // No celular, arrastar o cabeçalho para baixo fecha o painel.
  void _onDragUpdate(DragUpdateDetails d) {
    setState(() {
      _dragging = true;
      _drag = (_drag + d.delta.dy).clamp(0.0, double.infinity);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    if (_drag > 140 || d.velocity.pixelsPerSecond.dy > 700) {
      _close();
    }
    setState(() {
      _dragging = false;
      _drag = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final wide = screen.width >= _wideBreakpoint;
    final curved = CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final sheet = _Sheet(
      project: widget.project,
      images: _images,
      wide: wide,
      animation: curved,
      onClose: _close,
      onRetry: () => setState(() => _images = _load()),
      onHandleDragUpdate: wide ? null : _onDragUpdate,
      onHandleDragEnd: wide ? null : _onDragEnd,
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _close,
      },
      child: Focus(
        autofocus: true,
        child: Stack(
          children: [
            // Desfoque do site atrás, acompanhando a animação.
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: curved,
                  builder: (context, _) => BackdropFilter(
                    filter: ui.ImageFilter.blur(
                      sigmaX: 8 * curved.value,
                      sigmaY: 8 * curved.value,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            if (wide)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 980,
                      maxHeight: screen.height * 0.9,
                    ),
                    child: sheet,
                  ),
                ),
              )
            else
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: _dragging
                      ? Duration.zero
                      : const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  transform: Matrix4.translationValues(0, _drag, 0),
                  height: screen.height * 0.94,
                  child: sheet,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  final Map<String, dynamic> project;
  final Future<List<Uint8List>> images;
  final bool wide;
  final Animation<double> animation;
  final VoidCallback onClose;
  final VoidCallback onRetry;
  final GestureDragUpdateCallback? onHandleDragUpdate;
  final GestureDragEndCallback? onHandleDragEnd;

  const _Sheet({
    required this.project,
    required this.images,
    required this.wide,
    required this.animation,
    required this.onClose,
    required this.onRetry,
    this.onHandleDragUpdate,
    this.onHandleDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    const radius = 28.0;
    final shape = wide
        ? BorderRadius.circular(radius)
        : const BorderRadius.vertical(top: Radius.circular(radius));

    // O cabeçalho fica parado para o Hero pousar nele; o resto da folha
    // aparece por trás, subindo levemente.
    final body = FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(animation),
        child: _Body(
          project: project,
          images: images,
          wide: wide,
          onRetry: onRetry,
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: FadeTransition(
              opacity: animation,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ColorsApp.background(context),
                  borderRadius: shape,
                  border: Border.all(color: ColorsApp.border(context)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x55000000),
                      blurRadius: 60,
                      offset: Offset(0, 24),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: shape,
            child: Column(
              children: [
                GestureDetector(
                  onVerticalDragUpdate: onHandleDragUpdate,
                  onVerticalDragEnd: onHandleDragEnd,
                  child: _Header(
                    project: project,
                    wide: wide,
                    animation: animation,
                    onClose: onClose,
                  ),
                ),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Map<String, dynamic> project;
  final bool wide;
  final Animation<double> animation;
  final VoidCallback onClose;

  const _Header({
    required this.project,
    required this.wide,
    required this.animation,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final name = '${project['name'] ?? ''}';
    final platform = '${project['platform'] ?? ''}';
    final state = '${project['state'] ?? ''}';
    final description = '${project['description'] ?? ''}';
    final pad = wide ? 32.0 : 22.0;

    // Os textos só aparecem na segunda metade, depois que a capa pousou.
    final textIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.45, 1, curve: Curves.easeOut),
    );

    return SizedBox(
      height: wide ? 280 : 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: ProjectCover.heroTag(project),
            flightShuttleBuilder: (context, anim, direction, from, to) =>
                ProjectCover.flightShuttle(
              context,
              anim,
              direction,
              from,
              to,
              name,
            ),
            child: ProjectCoverBackdrop(name: name, scale: 260),
          ),
          FadeTransition(
            opacity: textIn,
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, wide ? 26 : 14, pad, pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!wide)
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      // Expanded (e não Flexible + Spacer): o espaço que o
                      // texto não usa fica aqui, e o fechar vai para a borda.
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                platform.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.4,
                                ),
                              ),
                            ),
                            if (state.isNotEmpty) ...[
                              const SizedBox(width: 12),
                              _GlassPill(text: state),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _CloseButton(onPressed: onClose),
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
                        fontSize: wide ? 38 : 28,
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: wide ? 16 : 14,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _Actions(project: project),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final Map<String, dynamic> project;

  const _Actions({required this.project});

  Future<void> _open(String link) async {
    final url = Uri.tryParse(link);
    if (url != null && await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = '${project['repositoryLink'] ?? ''}';
    final live = '${project['link'] ?? ''}';
    const shape = StadiumBorder();
    const padding = EdgeInsets.symmetric(horizontal: 18, vertical: 14);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (repo.isNotEmpty)
          FilledButton.icon(
            onPressed: () => _open(repo),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F172A),
              minimumSize: const Size(44, 44),
              padding: padding,
              shape: shape,
            ),
            icon: const Icon(EvaIcons.githubOutline, size: 18),
            label: const Text('Repositório'),
          ),
        Tooltip(
          message: live.isEmpty ? 'Ainda não publicado' : '',
          child: OutlinedButton.icon(
            onPressed: live.isEmpty ? null : () => _open(live),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white.withValues(alpha: 0.45),
              minimumSize: const Size(44, 44),
              padding: padding,
              shape: shape,
              side: BorderSide(
                color: Colors.white.withValues(alpha: live.isEmpty ? 0.2 : 0.5),
              ),
            ),
            icon: Icon(
              live.isEmpty ? Icons.schedule_rounded : Icons.open_in_new_rounded,
              size: 18,
            ),
            label: Text(live.isEmpty ? 'Em breve' : 'Ver online'),
          ),
        ),
      ],
    );
  }
}

class _GlassPill extends StatelessWidget {
  final String text;

  const _GlassPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CloseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Fechar (Esc)',
      onPressed: onPressed,
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
        backgroundColor: Colors.white.withValues(alpha: 0.14),
        foregroundColor: Colors.white,
      ),
      icon: const Icon(Icons.close_rounded, size: 20),
    );
  }
}

class _Body extends StatelessWidget {
  final Map<String, dynamic> project;
  final Future<List<Uint8List>> images;
  final bool wide;
  final VoidCallback onRetry;

  const _Body({
    required this.project,
    required this.images,
    required this.wide,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final techs = [
      for (final t in (project['technologiesUsed'] as List? ?? const [])) '$t',
    ];
    final features = [
      for (final f in (project['functionalities'] as List? ?? const [])) '$f',
    ];
    final pad = wide ? 32.0 : 20.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(pad, pad, pad, pad + 16),
      children: [
        _InfoTiles(project: project, wide: wide),
        if (techs.isNotEmpty) ...[
          const _SectionTitle('Tecnologias'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final t in techs) _TechChip(text: t)],
          ),
        ],
        if (features.isNotEmpty) ...[
          const _SectionTitle('Funcionalidades'),
          _Features(features: features, columns: wide ? 2 : 1),
        ],
        const _SectionTitle('Galeria'),
        _Gallery(
          project: project,
          images: images,
          wide: wide,
          onRetry: onRetry,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 14),
      child: Semantics(
        header: true,
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: ColorsApp.accent(context),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.6,
          ),
        ),
      ),
    );
  }
}

class _InfoTiles extends StatelessWidget {
  final Map<String, dynamic> project;
  final bool wide;

  const _InfoTiles({required this.project, required this.wide});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      for (final (icon, label, key) in [
        (Icons.devices_rounded, 'Plataforma', 'platform'),
        (Icons.person_outline_rounded, 'Minha função', 'myFunction'),
        (Icons.flag_outlined, 'Status', 'state'),
      ])
        if ('${project[key] ?? ''}'.isNotEmpty)
          _InfoTile(icon: icon, label: label, value: '${project[key]}'),
    ];

    if (!wide) {
      return Column(
        children: [
          for (final t in tiles)
            Padding(padding: const EdgeInsets.only(bottom: 10), child: t),
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: tiles[i]),
          ],
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsApp.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColorsApp.border(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: ColorsApp.accent(context).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: ColorsApp.accent(context)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: ColorsApp.muted(context),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: ColorsApp.letters(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
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

class _TechChip extends StatelessWidget {
  final String text;

  const _TechChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final accent = ColorsApp.accent(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: ColorsApp.letters(context),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Features extends StatelessWidget {
  final List<String> features;
  final int columns;

  const _Features({required this.features, required this.columns});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        const gap = 12.0;
        final itemW = (box.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final f in features)
              SizedBox(
                width: itemW,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 1),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: ColorsApp.accent(context),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: ColorsApp.onAccent(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        f,
                        style: TextStyle(
                          color: ColorsApp.letters(context),
                          fontSize: 15,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Faixa horizontal de capturas; tocar abre o visualizador em tela cheia.
class _Gallery extends StatelessWidget {
  final Map<String, dynamic> project;
  final Future<List<Uint8List>> images;
  final bool wide;
  final VoidCallback onRetry;

  const _Gallery({
    required this.project,
    required this.images,
    required this.wide,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final vertical = '${project['orientation']}' == 'vertical';
    final height = vertical ? (wide ? 380.0 : 320.0) : (wide ? 260.0 : 200.0);
    final aspect = vertical ? 0.48 : 1.6;
    final name = '${project['name'] ?? ''}';

    return FutureBuilder<List<Uint8List>>(
      future: images,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _GallerySkeleton(height: height, width: height * aspect);
        }
        if (snapshot.hasError) {
          return _GalleryMessage(
            icon: Icons.cloud_off_rounded,
            text: 'Não foi possível carregar as imagens.',
            action: TextButton(
              onPressed: onRetry,
              child: const Text('Tentar de novo'),
            ),
          );
        }
        final list = snapshot.data ?? const <Uint8List>[];
        if (list.isEmpty) {
          return const _GalleryMessage(
            icon: Icons.image_not_supported_outlined,
            text: 'Este projeto ainda não tem imagens.',
          );
        }
        return SizedBox(
          height: height,
          child: ScrollConfiguration(
            // No web o mouse também arrasta a faixa.
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: PointerDeviceKind.values.toSet(),
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _Thumb(
                bytes: list[i],
                width: height * aspect,
                heroTag: '$name-image-$i',
                label: 'Imagem ${i + 1} de ${list.length}',
                onTap: () => _openViewer(context, list, i, name),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Thumb extends StatefulWidget {
  final Uint8List bytes;
  final double width;
  final String heroTag;
  final String label;
  final VoidCallback onTap;

  const _Thumb({
    required this.bytes,
    required this.width,
    required this.heroTag,
    required this.label,
    required this.onTap,
  });

  @override
  State<_Thumb> createState() => _ThumbState();
}

class _ThumbState extends State<_Thumb> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.zoomIn,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _hover ? 1.02 : 1,
            duration: const Duration(milliseconds: 180),
            child: Container(
              width: widget.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColorsApp.border(context)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Hero(
                tag: widget.heroTag,
                child: AppMemoryImage(
                  bytes: widget.bytes,
                  width: widget.width,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GallerySkeleton extends StatefulWidget {
  final double height;
  final double width;

  const _GallerySkeleton({required this.height, required this.width});

  @override
  State<_GallerySkeleton> createState() => _GallerySkeletonState();
}

class _GallerySkeletonState extends State<_GallerySkeleton>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Carregando imagens',
      child: SizedBox(
        height: widget.height,
        child: ClipRect(
          child: FadeTransition(
            opacity: Tween(begin: 0.45, end: 1.0).animate(_pulse),
            child: Row(
              children: [
                for (var i = 0; i < 4; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Container(
                    width: widget.width,
                    decoration: BoxDecoration(
                      color: ColorsApp.surface(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ColorsApp.border(context)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryMessage extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? action;

  const _GalleryMessage({required this.icon, required this.text, this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColorsApp.border(context)),
      ),
      child: Column(
        children: [
          Icon(icon, color: ColorsApp.muted(context)),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: ColorsApp.muted(context)),
          ),
          if (action != null) ...[const SizedBox(height: 4), action!],
        ],
      ),
    );
  }
}

void _openViewer(
  BuildContext context,
  List<Uint8List> images,
  int initial,
  String name,
) {
  Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      barrierDismissible: true,
      barrierLabel: 'Fechar imagem',
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, _) => FadeTransition(
        opacity: animation,
        child: _ImageViewer(images: images, initial: initial, name: name),
      ),
    ),
  );
}

/// Visualizador em tela cheia: deslize entre as imagens, pinça para zoom,
/// setas e Esc no teclado.
class _ImageViewer extends StatefulWidget {
  final List<Uint8List> images;
  final int initial;
  final String name;

  const _ImageViewer({
    required this.images,
    required this.initial,
    required this.name,
  });

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  late final _controller = PageController(initialPage: widget.initial);
  late int _index = widget.initial;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int by) {
    final next = (_index + by).clamp(0, widget.images.length - 1);
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _close() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;
    final count = widget.images.length;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _close,
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _go(-1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _go(1),
      },
      child: Focus(
        autofocus: true,
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: count,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) => GestureDetector(
                // Tocar fora da imagem fecha.
                onTap: _close,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: wide ? 96 : 12,
                    vertical: 72,
                  ),
                  child: InteractiveViewer(
                    maxScale: 4,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {}, // tocar na imagem não fecha
                        child: Hero(
                          tag: '${widget.name}-image-$i',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              widget.images[i],
                              fit: BoxFit.contain,
                              gaplessPlayback: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 20,
              right: 16,
              child: SafeArea(
                child: Row(
                  children: [
                    Text(
                      '${_index + 1} / $count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        letterSpacing: 1.4,
                        fontFeatures: [ui.FontFeature.tabularFigures()],
                      ),
                    ),
                    const Spacer(),
                    _CloseButton(onPressed: _close),
                  ],
                ),
              ),
            ),
            if (wide && count > 1) ...[
              Positioned(
                left: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _ViewerArrow(
                    icon: Icons.chevron_left_rounded,
                    tooltip: 'Imagem anterior',
                    onPressed: _index > 0 ? () => _go(-1) : null,
                  ),
                ),
              ),
              Positioned(
                right: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _ViewerArrow(
                    icon: Icons.chevron_right_rounded,
                    tooltip: 'Próxima imagem',
                    onPressed: _index < count - 1 ? () => _go(1) : null,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ViewerArrow extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _ViewerArrow({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        minimumSize: const Size(52, 52),
        backgroundColor: Colors.white.withValues(alpha: 0.12),
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white.withValues(alpha: 0.25),
        disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
      ),
      icon: Icon(icon, size: 28),
    );
  }
}
