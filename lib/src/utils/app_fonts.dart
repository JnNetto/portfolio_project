import 'package:flutter/material.dart';

/// Local ABeeZee already bundled in [pubspec.yaml].
/// Avoids google_fonts runtime network fetch on web.
abstract final class AppFonts {
  static TextStyle aBeeZee({
    TextStyle? textStyle,
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return (textStyle ?? const TextStyle()).copyWith(
      fontFamily: 'ABeeZee',
      fontSize: fontSize ?? textStyle?.fontSize,
      color: color ?? textStyle?.color,
      fontWeight: fontWeight ?? textStyle?.fontWeight,
    );
  }

  static TextStyle poppins({
    TextStyle? textStyle,
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return aBeeZee(
      textStyle: textStyle,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }
}
