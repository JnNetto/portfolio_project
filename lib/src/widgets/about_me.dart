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
        flex: constraints.maxWidth > 1050 ? 2 : 3,
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
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      data["about"] ?? "No description",
      style: GoogleFonts.aBeeZee(
          textStyle: TextStyle(
              fontSize: constraints.maxWidth > 1050 ? 20 : 20,
              color: ColorsApp.letters)),
      softWrap: true,
    ),
  );
}
