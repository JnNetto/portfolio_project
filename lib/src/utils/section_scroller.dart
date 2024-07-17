import 'package:flutter/material.dart';
import 'package:portfolio/src/utils/colors.dart';
import 'package:portfolio/src/utils/hover_text.dart';

class SectionScroller {
  final ScrollController scrollController = ScrollController();

  final GlobalKey initialInfoKey = GlobalKey();
  final GlobalKey aboutMeKey = GlobalKey();
  final GlobalKey projectsKey = GlobalKey();
  final GlobalKey attributesKey = GlobalKey();
  final GlobalKey contactKey = GlobalKey();

  OverlayEntry? _overlayEntry;

  void scrollToSection(GlobalKey key) {
    if (key.currentContext != null) {
      final context = key.currentContext!;
      Scrollable.ensureVisible(context,
          duration: const Duration(seconds: 1), curve: Curves.easeInOut);
    }
  }

  List<Widget> buildAppBarButtons(BoxConstraints constraints) {
    return [
      HoverText(
        text: "Início",
        onPressed: () => scrollToSection(initialInfoKey),
        lettersColor: ColorsApp.letters,
        fontSize: 15,
      ),
      HoverText(
        text: "Sobre mim",
        onPressed: () => scrollToSection(aboutMeKey),
        lettersColor: ColorsApp.letters,
        fontSize: 15,
      ),
      HoverText(
        text: "Projetos",
        onPressed: () => scrollToSection(projectsKey),
        lettersColor: ColorsApp.letters,
        fontSize: 15,
      ),
      HoverText(
        text: "Atributos",
        onPressed: () => scrollToSection(attributesKey),
        lettersColor: ColorsApp.letters,
        fontSize: 15,
      ),
      HoverText(
        text: "Contato",
        onPressed: () => scrollToSection(contactKey),
        lettersColor: ColorsApp.letters,
        fontSize: 15,
      ),
      SizedBox(
        width: constraints.maxWidth * 0.15,
      )
    ];
  }

  Widget buildAppBarDrawer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: IconButton(
        icon: const Icon(
          Icons.menu,
          color: Colors.white,
        ),
        hoverColor: Colors.grey,
        onPressed: () {
          _toggleOverlay(context);
        },
      ),
    );
  }

  void _toggleOverlay(BuildContext context) {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } else {
      _overlayEntry = _createOverlayEntry(context);
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final size = overlay.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        right: size.width * 0.05,
        top: size.height * 0.4,
        child: _OverlayMenu(
          onIconPressed: (GlobalKey key) {
            scrollToSection(key);
            _toggleOverlay(context);
          },
          keys: {
            'initialInfoKey': initialInfoKey,
            'aboutMeKey': aboutMeKey,
            'projectsKey': projectsKey,
            'attributesKey': attributesKey,
            'contactKey': contactKey,
          },
        ),
      ),
    );
  }
}

class _OverlayMenu extends StatefulWidget {
  final Function(GlobalKey) onIconPressed;
  final Map<String, GlobalKey> keys;

  const _OverlayMenu({
    required this.onIconPressed,
    required this.keys,
  });

  @override
  __OverlayMenuState createState() => __OverlayMenuState();
}

class __OverlayMenuState extends State<_OverlayMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.reverse();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Material(
          color: Colors.transparent,
          child: OverlayItems(
              keys: widget.keys, onIconPressed: widget.onIconPressed)),
    );
  }
}

class OverlayItems extends StatelessWidget {
  final Function(GlobalKey) onIconPressed;
  final Map<String, GlobalKey> keys;

  const OverlayItems({
    super.key,
    required this.onIconPressed,
    required this.keys,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(23, 0, 0, 0).withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(
              Icons.home,
              color: Colors.white,
            ),
            onPressed: () => onIconPressed(keys['initialInfoKey']!),
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => onIconPressed(keys['aboutMeKey']!),
          ),
          IconButton(
            icon: const Icon(Icons.build, color: Colors.white),
            onPressed: () => onIconPressed(keys['projectsKey']!),
          ),
          IconButton(
            icon: const Icon(Icons.star, color: Colors.white),
            onPressed: () => onIconPressed(keys['attributesKey']!),
          ),
          IconButton(
            icon: const Icon(Icons.contact_mail, color: Colors.white),
            onPressed: () => onIconPressed(keys['contactKey']!),
          ),
        ],
      ),
    );
  }
}
