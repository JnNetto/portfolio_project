import 'package:flutter/material.dart';
import 'package:portfolio/src/utils/app_fonts.dart';
import '../utils/colors.dart';

class TextAboutMe extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;

  const TextAboutMe({
    super.key,
    required this.constraints,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    String aboutText = data["about"] ?? "No description";

    TextStyle defaultStyle = AppFonts.aBeeZee(
      textStyle: TextStyle(
        fontSize: constraints.maxWidth > 480 ? 17 : 16,
        height: 1.55,
        color: ColorsApp.letters(context),
      ),
    );

    TextStyle highlightedStyle = AppFonts.aBeeZee(
      textStyle: TextStyle(
        fontSize: constraints.maxWidth > 480 ? 17 : 16,
        height: 1.55,
        color: ColorsApp.letterButton(context),
        fontWeight: FontWeight.bold,
      ),
    );

    List<TextSpan> textSpans = [];
    bool highlight = false;
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < aboutText.length; i++) {
      if (aboutText[i] == '\$') {
        if (buffer.isNotEmpty) {
          textSpans.add(TextSpan(
            text: buffer.toString(),
            style: highlight ? highlightedStyle : defaultStyle,
          ));
          buffer.clear();
        }
        highlight = !highlight;
      } else {
        buffer.write(aboutText[i]);
      }
    }

    if (buffer.isNotEmpty) {
      textSpans.add(TextSpan(
        text: buffer.toString(),
        style: highlight ? highlightedStyle : defaultStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: textSpans),
      softWrap: true,
    );
  }
}
