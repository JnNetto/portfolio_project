import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../utils/colors.dart';

class AboutMe extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;

  const AboutMe({
    super.key,
    required this.constraints,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: constraints.maxWidth > 480
              ? constraints.maxWidth > 1050
                  ? 200
                  : 100
              : 50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("|| Sobre mim ||",
              style: GoogleFonts.aBeeZee(
                  textStyle: TextStyle(
                      fontSize: constraints.maxWidth > 480
                          ? 50
                          : constraints.maxWidth * .09,
                      color: ColorsApp.letters))),
          Visibility(
              visible: constraints.maxWidth <= 480,
              child: const SizedBox(
                height: 40,
              )),
          InfoAboutMe(constraints: constraints, data: data),
        ],
      ),
    );
  }
}

class InfoAboutMe extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;

  const InfoAboutMe({
    super.key,
    required this.constraints,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: TextAboutMe(constraints: constraints, data: data),
        ),
        SizedBox(
          height: constraints.maxWidth > 480 ? 100 : 0,
        ),
        AnimationLottie(constraints: constraints),
      ],
    );
  }
}

class AnimationLottie extends StatelessWidget {
  final BoxConstraints constraints;

  const AnimationLottie({
    super.key,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 1, bottom: 10),
      child: Lottie.asset("assets/animations/computer.json",
          width: constraints.maxWidth > 480 ? constraints.maxWidth * .35 : 0,
          fit: BoxFit.fill),
    );
  }
}

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

    TextStyle defaultStyle = GoogleFonts.aBeeZee(
      textStyle: TextStyle(
        fontSize: constraints.maxWidth > 480 ? 20 : 20,
        color: ColorsApp.letters,
      ),
    );

    TextStyle highlightedStyle = GoogleFonts.aBeeZee(
      textStyle: TextStyle(
        fontSize: constraints.maxWidth > 480 ? 20 : 20,
        color: ColorsApp.letterButton,
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
}
