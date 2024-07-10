import 'package:flutter/material.dart';

class SectionScroller {
  final ScrollController scrollController = ScrollController();

  final GlobalKey initialInfoKey = GlobalKey();
  final GlobalKey aboutMeKey = GlobalKey();
  final GlobalKey projectsKey = GlobalKey();
  final GlobalKey attributesKey = GlobalKey();
  final GlobalKey contactKey = GlobalKey();

  void scrollToSection(GlobalKey key) {
    final context = key.currentContext!;
    Scrollable.ensureVisible(context,
        duration: const Duration(seconds: 1), curve: Curves.easeInOut);
  }

  List<Widget> buildAppBarButtons() {
    return [
      TextButton(
        onPressed: () => scrollToSection(initialInfoKey),
        child: const Text("Início", style: TextStyle(color: Colors.white)),
      ),
      TextButton(
        onPressed: () => scrollToSection(aboutMeKey),
        child: const Text("Sobre Mim", style: TextStyle(color: Colors.white)),
      ),
      TextButton(
        onPressed: () => scrollToSection(projectsKey),
        child: const Text("Projetos", style: TextStyle(color: Colors.white)),
      ),
      TextButton(
        onPressed: () => scrollToSection(attributesKey),
        child: const Text("Atributos", style: TextStyle(color: Colors.white)),
      ),
      TextButton(
        onPressed: () => scrollToSection(contactKey),
        child: const Text("Contato", style: TextStyle(color: Colors.white)),
      ),
    ];
  }
}
