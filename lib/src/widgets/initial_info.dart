import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:portfolio/src/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class InitialInfo extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;

  const InitialInfo({
    super.key,
    required this.constraints,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: constraints.maxWidth > 1050 ? 200 : 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: constraints.maxWidth > 1050
                    ? 200
                    : constraints.maxHeight * .35),
            child: Info(constraints: constraints, data: data),
          ),
          SizedBox(
            width: constraints.maxWidth * 0.05,
          ),
          Visibility(
            visible: constraints.maxWidth > 1050,
            child: AnimationLottie(constraints: constraints),
          ),
        ],
      ),
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
    return Lottie.asset(
      "assets/animations/cellphone.json",
      width: constraints.maxWidth > 1050 ? constraints.maxWidth * .35 : 0,
      height: constraints.maxWidth > 1050 ? constraints.maxHeight * .75 : 0,
      fit: BoxFit.fill,
    );
  }
}

class Info extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;

  const Info({
    super.key,
    required this.constraints,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Name(constraints: constraints, data: data),
        const SizedBox(height: 10),
        Occupation(constraints: constraints, data: data),
        const SizedBox(height: 10),
        SocialNetwork(data: data),
      ],
    );
  }
}

class SocialNetwork extends StatelessWidget {
  final Map<String, dynamic> data;

  const SocialNetwork({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    List links = data["socialNetwork"];
    List icons = [EvaIcons.linkedinOutline, EvaIcons.githubOutline];
    List<Map<String, dynamic>> items = [];

    items = listSocialNetworks(links, icons);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: items.map((item) {
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

  List<Map<String, dynamic>> listSocialNetworks(List links, List icons) {
    List<Map<String, dynamic>> items = [];

    for (var i = 0; i < links.length; i++) {
      items.add({'icon': icons[i], 'url': links[i]});
    }

    return items;
  }
}

class Occupation extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;

  const Occupation({
    super.key,
    required this.constraints,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          data["occupation"] ?? "No description",
          textStyle: TextStyle(
            fontSize: constraints.maxWidth > 1050 ? 30 : 25,
            color: ColorsApp.letters,
          ),
          speed: const Duration(milliseconds: 200),
        ),
      ],
      totalRepeatCount: 50,
      pause: const Duration(milliseconds: 3000),
    );
  }
}

class Name extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;

  const Name({
    super.key,
    required this.constraints,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      data["name"] ?? "No title",
      softWrap: true,
      style: GoogleFonts.aBeeZee(
        textStyle: TextStyle(
          fontSize: constraints.maxWidth > 1050 ? 50 : 35,
          color: ColorsApp.letters,
        ),
      ),
    );
  }
}
