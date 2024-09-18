import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/src/utils/colors.dart';
import 'package:portfolio/src/utils/hover_text.dart';

class SectionScroller {
  final ScrollController scrollController = ScrollController();

  final GlobalKey initialInfoKey = GlobalKey();
  final GlobalKey aboutMeKey = GlobalKey();
  final GlobalKey projectsKey = GlobalKey();
  final GlobalKey attributesKey = GlobalKey();
  final GlobalKey contactKey = GlobalKey();

  void scrollToSection(GlobalKey key) {
    if (key.currentContext != null) {
      final context = key.currentContext!;
      Scrollable.ensureVisible(context,
          duration: const Duration(seconds: 1), curve: Curves.easeInOut);
    }
  }

  List<Widget> buildAppBarButtons(
      BoxConstraints constraints, BuildContext context) {
    return [
      HoverText(
        text: "Início",
        onPressed: () => scrollToSection(initialInfoKey),
        lettersColor: Colors.white,
        fontSize: constraints.maxWidth > 1050 ? 15 : 21,
      ),
      HoverText(
        text: "Sobre mim",
        onPressed: () => scrollToSection(aboutMeKey),
        lettersColor: Colors.white,
        fontSize: constraints.maxWidth > 1050 ? 15 : 21,
      ),
      HoverText(
        text: "Projetos",
        onPressed: () => scrollToSection(projectsKey),
        lettersColor: Colors.white,
        fontSize: constraints.maxWidth > 1050 ? 15 : 21,
      ),
      HoverText(
        text: "Habilidades",
        onPressed: () => scrollToSection(attributesKey),
        lettersColor: Colors.white,
        fontSize: constraints.maxWidth > 1050 ? 15 : 21,
      ),
      HoverText(
        text: "Contato",
        onPressed: () => scrollToSection(contactKey),
        lettersColor: Colors.white,
        fontSize: constraints.maxWidth > 1050 ? 15 : 21,
      ),
      SizedBox(
        width: constraints.maxWidth > 1050
            ? constraints.maxWidth * 0.15
            : constraints.maxWidth * 0.05,
      )
    ];
  }

  Widget buildAppBarDrawer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: PopupMenuButton<String>(
        color: ColorsApp.backgroundDetails(context),
        icon: const Icon(
          Icons.menu,
          color: Colors.white,
        ),
        popUpAnimationStyle:
            AnimationStyle(curve: Curves.fastEaseInToSlowEaseOut),
        onSelected: (String key) {
          switch (key) {
            case 'initialInfoKey':
              scrollToSection(initialInfoKey);
              break;
            case 'aboutMeKey':
              scrollToSection(aboutMeKey);
              break;
            case 'projectsKey':
              scrollToSection(projectsKey);
              break;
            case 'attributesKey':
              scrollToSection(attributesKey);
              break;
            case 'contactKey':
              scrollToSection(contactKey);
              break;
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'initialInfoKey',
            child: Text('Início', style: stylePopup(context)),
          ),
          PopupMenuItem<String>(
            value: 'aboutMeKey',
            child: Text('Sobre mim', style: stylePopup(context)),
          ),
          PopupMenuItem<String>(
            value: 'projectsKey',
            child: Text('Projetos', style: stylePopup(context)),
          ),
          PopupMenuItem<String>(
            value: 'attributesKey',
            child: Text('Habilidades', style: stylePopup(context)),
          ),
          PopupMenuItem<String>(
            value: 'contactKey',
            child: Text('Contato', style: stylePopup(context)),
          ),
        ],
      ),
    );
  }

  TextStyle stylePopup(BuildContext context) {
    return GoogleFonts.aBeeZee(
        textStyle: TextStyle(color: ColorsApp.letters(context), fontSize: 20));
  }
}
