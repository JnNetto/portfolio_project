import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:portfolio/src/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

Widget initialInfo(BoxConstraints constraints,
    {required Map<String, dynamic> data}) {
  return Padding(
    padding: const EdgeInsets.only(left: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        info(constraints, data: data),
        SizedBox(
          width: constraints.maxWidth * 0.05,
        ),
        animationLothie(constraints)
      ],
    ),
  );
}

Widget animationLothie(BoxConstraints constraints) {
  return Container(
    margin: const EdgeInsets.only(top: 1, bottom: 10),
    child: Lottie.asset("assets/animations/cellphone.json",
        width: constraints.maxWidth > 1050 ? constraints.maxWidth * .35 : 0,
        height: constraints.maxHeight > 650 ? constraints.maxHeight * .75 : 0,
        fit: BoxFit.fill),
  );
}

// ignore: non_constant_identifier_names
Widget info(BoxConstraints constraints, {required Map<String, dynamic> data}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      name(constraints, data: data),
      occupation(constraints, data: data),
      socialNetwork(data: data)
    ],
  );
}

Widget socialNetwork({required Map<String, dynamic> data}) {
  List links = data["socialNetwork"];
  List icons = [EvaIcons.linkedinOutline, EvaIcons.githubOutline];
  List<Map<String, dynamic>> itens = [];

  var item = listSocialNetworks(links, icons, itens);

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: item.map((item) {
      return IconButton(
        icon: Icon(
          item["icon"],
          color: Colors.white,
        ),
        hoverColor: Colors.grey,
        onPressed: () async {
          await launchUrl(Uri.parse(item["url"]));
        },
      );
    }).toList(),
  );
}

List listSocialNetworks(List links, List icons, List itens) {
  for (var i = 0; i < links.length; i++) {
    itens.add({'icon': icons[i], 'url': links[i]});
  }

  return itens;
}

AnimatedTextKit occupation(BoxConstraints constraints,
    {required Map<String, dynamic> data}) {
  return AnimatedTextKit(
    animatedTexts: [
      TypewriterAnimatedText(
        data["occupation"] ?? "No description",
        textStyle: TextStyle(
            fontSize: constraints.maxWidth > 1050 ? 30 : 25,
            color: ColorsApp.letters),
        speed: const Duration(milliseconds: 200),
      ),
    ],
    totalRepeatCount: 50,
    pause: const Duration(milliseconds: 3000),
  );
}

Widget name(BoxConstraints constraints, {required Map<String, dynamic> data}) {
  return Text(
    data["name"] ?? "No title",
    softWrap: true,
    style: GoogleFonts.aBeeZee(
        textStyle: TextStyle(
            fontSize: constraints.maxWidth > 1050 ? 50 : 35,
            color: ColorsApp.letters)),
  );
}
