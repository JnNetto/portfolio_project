import 'package:flutter/material.dart';

class ColorsApp {
  static Color backgroundLight = const Color.fromARGB(255, 171, 182, 244);
  static Color hoverButtonLight = const Color.fromARGB(255, 0, 119, 255);
  static Color hoverIconLight = const Color.fromARGB(255, 120, 174, 236);
  static Color backgroundDetailsLight =
      const Color.fromARGB(255, 164, 151, 201);
  static Color cardLight = const Color.fromARGB(255, 168, 193, 236);
  static Color letterButtonLight = const Color.fromARGB(255, 0, 68, 255);
  static Color shadowColorLight = const Color.fromARGB(255, 112, 61, 146);
  static Color borderLight = const Color.fromARGB(255, 71, 101, 169);
  static Color appbarLight = const Color.fromARGB(255, 64, 61, 77);
  static Color lettersLight = const Color.fromARGB(255, 0, 0, 0);
  static Color starsLight = const Color.fromARGB(255, 253, 227, 1);

  static Color backgroundDark = const Color.fromARGB(255, 7, 2, 22);
  static Color hoverButtonDark = const Color.fromARGB(255, 73, 155, 248);
  static Color hoverIconDark = const Color.fromARGB(255, 32, 23, 53);
  static Color backgroundDetailsDark = const Color.fromARGB(255, 17, 9, 40);
  static Color cardDark = const Color.fromARGB(255, 37, 30, 61);
  static Color letterButtonDark = const Color.fromARGB(255, 21, 130, 219);
  static Color shadowColorDark = const Color.fromARGB(255, 59, 46, 139);
  static Color borderDark = const Color.fromARGB(255, 51, 30, 182);
  static Color appbarDark = const Color.fromARGB(255, 44, 43, 51);
  static Color lettersDark = const Color.fromARGB(255, 255, 255, 255);
  static Color starsDark = Colors.yellow;

  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }

  static Color hoverButton(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? hoverButtonDark
        : hoverButtonLight;
  }

  static Color hoverIcon(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? hoverIconDark
        : hoverIconLight;
  }

  static Color backgroundDetails(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDetailsDark
        : backgroundDetailsLight;
  }

  static Color card(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? cardDark
        : cardLight;
  }

  static Color letterButton(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? letterButtonDark
        : letterButtonLight;
  }

  static Color shadowColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? shadowColorDark
        : shadowColorLight;
  }

  static Color border(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? borderDark
        : borderLight;
  }

  static Color appbar(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? appbarDark
        : appbarLight;
  }

  static Color letters(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? lettersDark
        : lettersLight;
  }

  static Color stars(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? starsDark
        : starsLight;
  }
}
