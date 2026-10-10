import 'package:flutter/material.dart';

class ColorsApp {
  static const Color backgroundLight = Color(0xFFE9EEF3);
  static const Color hoverButtonLight = Color(0xFF16A34A);
  static const Color hoverIconLight = Color(0xFFDCFCE7);
  static const Color backgroundDetailsLight = Color(0xFFF4F7FA);
  static const Color cardLight = Color(0xFFF4F7FA);
  static const Color letterButtonLight = Color(0xFF15803D);
  static const Color shadowColorLight = Color(0x331E293B);
  static const Color borderLight = Color(0xFFCBD5E1);
  static const Color appbarLight = Color(0xFF0F172A);
  static const Color lettersLight = Color(0xFF0F172A);
  static const Color starsLight = Color(0xFFFBBF24);
  static const Color mutedLight = Color(0xFF526073);
  static const Color accentLight = Color(0xFF16A34A);
  static const Color surfaceLight = Color(0xFFF4F7FA);

  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color hoverButtonDark = Color(0xFF4ADE80);
  static const Color hoverIconDark = Color(0xFF1E293B);
  static const Color backgroundDetailsDark = Color(0xFF1B2336);
  static const Color cardDark = Color(0xFF1B2336);
  static const Color letterButtonDark = Color(0xFF4ADE80);
  static const Color shadowColorDark = Color(0x66000000);
  static const Color borderDark = Color(0xFF334155);
  static const Color appbarDark = Color(0xFF0B1220);
  static const Color lettersDark = Color(0xFFF8FAFC);
  static const Color starsDark = Color(0xFFFACC15);
  static const Color mutedDark = Color(0xFF94A3B8);
  static const Color accentDark = Color(0xFF4ADE80);
  static const Color surfaceDark = Color(0xFF1B2336);

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      _isDark(context) ? backgroundDark : backgroundLight;

  static Color hoverButton(BuildContext context) =>
      _isDark(context) ? hoverButtonDark : hoverButtonLight;

  static Color hoverIcon(BuildContext context) =>
      _isDark(context) ? hoverIconDark : hoverIconLight;

  static Color backgroundDetails(BuildContext context) =>
      _isDark(context) ? backgroundDetailsDark : backgroundDetailsLight;

  static Color card(BuildContext context) =>
      _isDark(context) ? cardDark : cardLight;

  static Color letterButton(BuildContext context) =>
      _isDark(context) ? letterButtonDark : letterButtonLight;

  static Color shadowColor(BuildContext context) =>
      _isDark(context) ? shadowColorDark : shadowColorLight;

  static Color border(BuildContext context) =>
      _isDark(context) ? borderDark : borderLight;

  static Color appbar(BuildContext context) =>
      _isDark(context) ? appbarDark : appbarLight;

  static Color letters(BuildContext context) =>
      _isDark(context) ? lettersDark : lettersLight;

  static Color stars(BuildContext context) =>
      _isDark(context) ? starsDark : starsLight;

  static Color muted(BuildContext context) =>
      _isDark(context) ? mutedDark : mutedLight;

  static Color accent(BuildContext context) =>
      _isDark(context) ? accentDark : accentLight;

  static Color surface(BuildContext context) =>
      _isDark(context) ? surfaceDark : surfaceLight;

  static Color onAccent(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0F172A) : Colors.white;
}
