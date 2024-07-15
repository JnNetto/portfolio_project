import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../utils/colors.dart';

Widget aboutMe(BoxConstraints constraints,
    {required Map<String, dynamic> data}) {
  return Padding(
    padding: EdgeInsets.symmetric(
        horizontal: constraints.maxWidth > 1050 ? 200 : 50),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("|| Sobre mim ||",
            style: GoogleFonts.aBeeZee(
                textStyle: TextStyle(
                    fontSize: constraints.maxWidth > 1050 ? 50 : 40,
                    color: ColorsApp.letters))),
        infoAboutMe(constraints, data: data)
      ],
    ),
  );
}

Widget infoAboutMe(BoxConstraints constraints,
    {required Map<String, dynamic> data}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Expanded(
        child: textAboutMe(constraints, data: data),
      ),
      SizedBox(
        height: constraints.maxWidth > 1050 ? 40 : 0,
      ),
      animationLottie(constraints),
    ],
  );
}

Widget animationLottie(BoxConstraints constraints) {
  return Container(
    margin: const EdgeInsets.only(top: 1, bottom: 10),
    child: Lottie.asset("assets/animations/computer.json",
        width: constraints.maxWidth > 1050 ? constraints.maxWidth * .35 : 0,
        height: constraints.maxHeight > 650 ? constraints.maxHeight * .75 : 0,
        fit: BoxFit.fill),
  );
}

Widget textAboutMe(BoxConstraints constraints,
    {required Map<String, dynamic> data}) {
  String aboutText = data["about"] ?? "No description";
  TextStyle defaultStyle = GoogleFonts.aBeeZee(
    textStyle: TextStyle(
      fontSize: constraints.maxWidth > 1050 ? 20 : 20,
      color: ColorsApp.letters,
    ),
  );
  TextStyle highlightedStyle = GoogleFonts.aBeeZee(
    textStyle: TextStyle(
      fontSize: constraints.maxWidth > 1050 ? 20 : 20,
      color: ColorsApp.letterButton, // cor de destaque
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

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: RichText(
      text: TextSpan(children: textSpans),
      softWrap: true,
    ),
  );
}
