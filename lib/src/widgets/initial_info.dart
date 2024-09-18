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
          horizontal: constraints.maxWidth > 480 ? 200 : 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: constraints.maxWidth > 480
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

class AnimationLottie extends StatefulWidget {
  final BoxConstraints constraints;

  const AnimationLottie({
    super.key,
    required this.constraints,
  });

  @override
  State<AnimationLottie> createState() => _AnimationLottieState();
}

class _AnimationLottieState extends State<AnimationLottie>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
        Theme.of(context).brightness == Brightness.dark
            ? "assets/animations/cellphone.json"
            : "assets/animations/cellphoneLight.json",
        width: widget.constraints.maxWidth > 480
            ? widget.constraints.maxWidth * .35
            : 0,
        height: widget.constraints.maxWidth > 480
            ? widget.constraints.maxHeight * .75
            : 0,
        fit: BoxFit.fill,
        controller: Theme.of(context).brightness == Brightness.light
            ? _controller
            : null,
        repeat: true);
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
            color: ColorsApp.letters(context),
          ),
          hoverColor: ColorsApp.hoverIcon(context),
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
            fontSize: constraints.maxWidth > 480 ? 30 : 25,
            color: ColorsApp.letters(context),
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
          fontSize: constraints.maxWidth > 480 ? 50 : 35,
          color: ColorsApp.letters(context),
        ),
      ),
    );
  }
}
