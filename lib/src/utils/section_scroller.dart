import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/src/utils/colors.dart';

class SectionScroller {
  final ScrollController scrollController = ScrollController();

  final GlobalKey initialInfoKey = GlobalKey();
  final GlobalKey aboutMeKey = GlobalKey();
  final GlobalKey projectsKey = GlobalKey();
  final GlobalKey attributesKey = GlobalKey();
  final GlobalKey contactKey = GlobalKey();

  OverlayEntry? _overlayEntry;

  bool isHovered = false;

  void scrollToSection(GlobalKey key) {
    final context = key.currentContext!;
    Scrollable.ensureVisible(context,
        duration: const Duration(seconds: 1), curve: Curves.easeInOut);
  }

  List<Widget> buildAppBarButtons(BoxConstraints constraints) {
    return [
      TextButton(
        onPressed: () => scrollToSection(initialInfoKey),
        child: Text("Início",
            style: GoogleFonts.aBeeZee(
                textStyle: TextStyle(color: ColorsApp.letters))),
      ),
      TextButton(
        onPressed: () => scrollToSection(aboutMeKey),
        child: Text("Sobre Mim",
            style: GoogleFonts.aBeeZee(
                textStyle: TextStyle(color: ColorsApp.letters))),
      ),
      TextButton(
        onPressed: () => scrollToSection(projectsKey),
        child: Text("Projetos",
            style: GoogleFonts.aBeeZee(
                textStyle: TextStyle(color: ColorsApp.letters))),
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => scrollToSection(attributesKey),
            onHover: (value) {
              isHovered = value;
            },
            child: Text(
              "Atributos",
              style: GoogleFonts.aBeeZee(
                textStyle: TextStyle(color: ColorsApp.letters),
              ),
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: 2,
            width: isHovered ? 100 : 0,
            color: Colors.purple,
            margin: EdgeInsets.only(top: 4),
          ),
        ],
      ),
      TextButton(
        onPressed: () => scrollToSection(contactKey),
        child: Text("Contato",
            style: GoogleFonts.aBeeZee(
                textStyle: TextStyle(color: ColorsApp.letters))),
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
          showIconMenu(context);
        },
      ),
    );
  }

  void showIconMenu(BuildContext context) {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } else {
      final overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox;
      final size = overlay.size;

      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          right: size.width * 0.05,
          top: size.height * 0.4,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
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
                    onPressed: () {
                      scrollToSection(initialInfoKey);
                      _overlayEntry?.remove();
                      _overlayEntry = null;
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () {
                      scrollToSection(aboutMeKey);
                      _overlayEntry?.remove();
                      _overlayEntry = null;
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.build, color: Colors.white),
                    onPressed: () {
                      scrollToSection(projectsKey);
                      _overlayEntry?.remove();
                      _overlayEntry = null;
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.star, color: Colors.white),
                    onPressed: () {
                      scrollToSection(attributesKey);
                      _overlayEntry?.remove();
                      _overlayEntry = null;
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.contact_mail, color: Colors.white),
                    onPressed: () {
                      scrollToSection(contactKey);
                      _overlayEntry?.remove();
                      _overlayEntry = null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      Overlay.of(context).insert(_overlayEntry!);
    }
  }
}
