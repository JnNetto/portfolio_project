import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:portfolio/src/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

Widget initialInfo(BoxConstraints constraints) {
  return Padding(
    padding: const EdgeInsets.only(left: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        info(),
        SizedBox(
          width: constraints.maxWidth * 0.05,
        ),
        animationLothie()
      ],
    ),
  );
}

Widget animationLothie() {
  return Container(
    margin: const EdgeInsets.only(top: 1, bottom: 10),
    child: Lottie.asset("assets/animations/cellphone.json",
        width: 500, height: 500, fit: BoxFit.fill),
  );
}

// ignore: non_constant_identifier_names
Widget info() {
  final Uri linkedInUrl = Uri.parse('https://www.linkedin.com/');
  final Uri githubUrl = Uri.parse('https://github.com/');
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "João Antônio Gomes",
        style: GoogleFonts.aBeeZee(
            textStyle: TextStyle(fontSize: 50, color: ColorsApp.letters)),
      ),
      AnimatedTextKit(
        animatedTexts: [
          TypewriterAnimatedText(
            'Desenvolvedor Mobile',
            textStyle: TextStyle(fontSize: 30, color: ColorsApp.letters),
            speed: const Duration(milliseconds: 200),
          ),
        ],
        totalRepeatCount: 50,
        pause: const Duration(milliseconds: 3000),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.linked_camera),
            hoverColor: Colors.white,
            onPressed: () async {
              await launchUrl(linkedInUrl);
            },
          ),
          IconButton(
            icon: const Icon(Icons.code),
            hoverColor: Colors.white,
            onPressed: () async {
              await launchUrl(githubUrl);
            },
          ),
        ],
      )
    ],
  );
}
