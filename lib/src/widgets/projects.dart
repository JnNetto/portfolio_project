import 'dart:collection';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:portfolio/src/utils/hover_button.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/colors.dart';
import '../utils/grid_menus.dart';

Widget projects(BoxConstraints constraints,
    {required Map<String, dynamic> data}) {
  final CarouselController controller = CarouselController();
  List<Object?> projects = data["projects"];
  return Column(
    children: [
      Padding(
        padding: EdgeInsets.only(bottom: constraints.maxWidth > 1050 ? 60 : 40),
        child: Text("|| Projetos ||",
            style: GoogleFonts.aBeeZee(
                textStyle: TextStyle(
                    fontSize: constraints.maxWidth > 1050 ? 50 : 40,
                    color: ColorsApp.letters))),
      ),
      sliderProjects(constraints, projects, controller),
    ],
  );
}

Widget sliderProjects(
    BoxConstraints constraints, List projects, CarouselController controller) {
  return Stack(
    children: [
      Padding(
        padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 1050 ? 250 : 0),
        child: projects.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : CarouselSlider.builder(
                options: CarouselOptions(
                  height: 400,
                  enlargeCenterPage: true,
                  autoPlay: false,
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.easeInExpo,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  viewportFraction: constraints.maxWidth > 1050 ? 0.4 : 0.7,
                ),
                carouselController: controller,
                itemCount: projects.length,
                itemBuilder: (context, index, realIdx) {
                  final projectLinkedMap = projects[index] as LinkedHashMap;
                  final project = Map<String, dynamic>.from(projectLinkedMap);
                  return projectCard(context, constraints, project: project);
                },
              ),
      ),
      gradientEffect(constraints, Alignment.centerLeft, Alignment.centerRight,
          Alignment.centerLeft),
      gradientEffect(constraints, Alignment.centerRight, Alignment.centerLeft,
          Alignment.centerRight),
      Positioned(
        left: constraints.maxWidth > 1050 ? 50 : 10,
        top: 175,
        child: IconButton(
          icon: const Icon(Icons.arrow_back, size: 25, color: Colors.white70),
          onPressed: () => controller.previousPage(),
        ),
      ),
      Positioned(
        right: constraints.maxWidth > 1050 ? 50 : 10,
        top: 175,
        child: IconButton(
          icon:
              const Icon(Icons.arrow_forward, size: 25, color: Colors.white70),
          onPressed: () => controller.nextPage(),
        ),
      ),
    ],
  );
}

gradientEffect(BoxConstraints constraints, Alignment align, Alignment begin,
    Alignment end) {
  return Visibility(
    visible: constraints.maxWidth > 1050,
    child: Padding(
      padding: EdgeInsets.symmetric(
          horizontal: constraints.maxWidth > 1050 ? 248 : 0),
      child: Align(
        alignment: align,
        child: Container(
          width: 80,
          height: 400,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: [
                Colors.transparent,
                ColorsApp.background.withOpacity(0.09),
                ColorsApp.background.withOpacity(0.19),
                ColorsApp.background.withOpacity(0.29),
                ColorsApp.background.withOpacity(0.39),
                ColorsApp.background.withOpacity(0.49),
                ColorsApp.background.withOpacity(0.59),
                ColorsApp.background.withOpacity(0.69),
                ColorsApp.background.withOpacity(0.79),
                ColorsApp.background.withOpacity(0.89),
                ColorsApp.background.withOpacity(0.99),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget projectCard(BuildContext context, BoxConstraints constraints,
    {required Map<String, dynamic> project}) {
  return ConstrainedBox(
    constraints: BoxConstraints(
        minWidth: constraints.maxWidth > 1050 ? 500 : 250,
        maxWidth: constraints.maxWidth > 1050 ? 500 : 250),
    child: Container(
      decoration: BoxDecoration(
        color: ColorsApp.card,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: ColorsApp.shadowColor,
          width: constraints.maxWidth > 1050 ? 6 : 4,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorsApp.shadowColor,
            blurRadius: 10,
            spreadRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                          child: texts(constraints, project: project))),
                  Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                          child: buttonsToSee(context, constraints,
                              project: project)))
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Text(
                project["state"],
                style: GoogleFonts.aBeeZee(fontSize: 22, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget texts(BoxConstraints constraints,
    {required Map<String, dynamic> project}) {
  return Column(
    children: [
      Text(
        project["name"],
        style: GoogleFonts.aBeeZee(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: ColorsApp.letters),
      ),
      Text(
        project["description"],
        textAlign: TextAlign.center,
        style: GoogleFonts.aBeeZee(
            fontSize: constraints.maxWidth > 1050 ? 20 : 15,
            fontWeight: FontWeight.bold,
            color: ColorsApp.letters),
      ),
    ],
  );
}

Widget buttonsToSee(BuildContext context, BoxConstraints constraints,
    {required Map<String, dynamic> project}) {
  return Column(
    children: [
      repositoryLink(constraints, project: project),
      const SizedBox(height: 7.5),
      deployedApplication(constraints, context, project: project),
      const SizedBox(height: 7.5),
      HoverButton(
        text: "Ver detalhes",
        onPressed: () {
          details(context, constraints, project: project);
        },
        lettersColor: ColorsApp.letterButton,
        fontSize: constraints.maxWidth > 1050 ? 20 : 16,
      )
    ],
  );
}

Widget repositoryLink(BoxConstraints constraints,
    {required Map<String, dynamic> project}) {
  return HoverButton(
    text: "Ver Repositório",
    onPressed: () async {
      await launchUrl(Uri.parse(project["repositoryLink"]));
    },
    lettersColor: ColorsApp.letterButton,
    fontSize: constraints.maxWidth > 1050 ? 20 : 16,
  );
}

Widget deployedApplication(BoxConstraints constraints, BuildContext context,
    {required Map<String, dynamic> project}) {
  return HoverButton(
      text: "Ver aplicação no ar",
      onPressed: () async {
        if (project["link"] == "") {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: ColorsApp.background,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: animationLothie(constraints),
                      ),
                      SizedBox(
                        height: constraints.maxWidth > 1050 ? 20 : 10,
                      ),
                      Text(
                        "Parece que ainda não está publicado.",
                        style: GoogleFonts.aBeeZee(
                            fontSize: constraints.maxWidth > 1050 ? 20 : 13,
                            color: ColorsApp.letters),
                      ),
                      Text(
                        "Tente novamente em breve!",
                        style: GoogleFonts.aBeeZee(
                            fontSize: constraints.maxWidth > 1050 ? 20 : 13,
                            color: ColorsApp.letters),
                      )
                    ],
                  ),
                );
              });
        } else {
          await launchUrl(Uri.parse(project["link"]));
        }
      },
      lettersColor: ColorsApp.letterButton,
      fontSize: constraints.maxWidth > 1050 ? 20 : 16);
}

void details(BuildContext context, BoxConstraints constraints,
    {required Map<String, dynamic> project}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      List<String> funcionalidades =
          List<String>.from(project["functionalities"]);
      List<String> imagens = List<String>.from(project["images"]);
      String plataforma = project["platform"];
      String minhaFuncao = project["myFunction"];
      return Stack(
        children: [
          arrowBackButton(context),
          AlertDialog(
            backgroundColor: ColorsApp.card,
            title: Center(
              child: Text("Detalhes",
                  style: GoogleFonts.aBeeZee(
                      fontSize: constraints.maxWidth > 1050 ? 32 : 26,
                      color: ColorsApp.letters)),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Text("Tipo de plataforma: $plataforma",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.aBeeZee(
                          fontSize: constraints.maxWidth > 1050 ? 20 : 18,
                          color: ColorsApp.letters)),
                  const SizedBox(
                    height: 20,
                  ),
                  Text("Função desempenhada: $minhaFuncao",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.aBeeZee(
                          fontSize: constraints.maxWidth > 1050 ? 20 : 18,
                          color: ColorsApp.letters)),
                  const SizedBox(
                    height: 20,
                  ),
                  Text("Funcionalidades do projeto",
                      style: GoogleFonts.aBeeZee(
                          fontSize: constraints.maxWidth > 1050 ? 24 : 23,
                          color: ColorsApp.letters)),
                  functionalities(funcionalidades),
                  const SizedBox(
                    height: 20,
                  ),
                  Text("Imagens do projeto",
                      style: GoogleFonts.aBeeZee(
                          fontSize: constraints.maxWidth > 1050 ? 24 : 23,
                          color: ColorsApp.letters)),
                  images(imagens, plataforma, context, constraints),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget animationLothie(BoxConstraints constraints) {
  return Container(
    margin: const EdgeInsets.only(top: 1, bottom: 10),
    child: Lottie.asset("assets/animations/construction.json",
        width: constraints.maxWidth > 1050
            ? constraints.maxWidth * .3
            : constraints.maxWidth,
        height: constraints.maxHeight > 1000
            ? constraints.maxHeight * .5
            : constraints.maxHeight * .3,
        fit: BoxFit.fill),
  );
}

Widget functionalities(List<String> funcionalidades) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: funcionalidades.map((funcionalidade) {
      return ListTile(
        leading: Icon(Icons.check, color: ColorsApp.letters),
        title: Text(
          funcionalidade,
          style: GoogleFonts.aBeeZee(fontSize: 16, color: ColorsApp.letters),
        ),
      );
    }).toList(),
  );
}

Widget images(List<String> imagens, String plataforma, BuildContext context,
    BoxConstraints constraints) {
  int halfLength = imagens.length <= 3 ? 3 : (imagens.length / 2).ceil();
  late double? width;
  if (plataforma == "Mobile") {
    if (constraints.maxWidth > 1050) {
      width = 150;
    } else {
      width = 70;
    }
  } else {
    if (constraints.maxWidth > 1050) {
      width = 350;
    } else {
      width = 250;
    }
  }
  return GridMenus(
    contentLine1: imagens.take(halfLength).map((image) {
      return GestureDetector(
        onTap: () {
          zoom(context, image);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.memory(
            base64Decode(image),
            width: width,
            fit: BoxFit.cover,
          ),
        ),
      );
    }).toList(),
    contentLine2: imagens.skip(halfLength).map((image) {
      return GestureDetector(
        onTap: () {
          zoom(context, image);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.memory(base64Decode(image), width: width),
        ),
      );
    }).toList(),
  );
}

dynamic zoom(
  BuildContext context,
  String image,
) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.memory(
                base64Decode(image),
                fit: BoxFit.contain,
              ),
            ),
            arrowBackButton(context)
          ],
        ),
      );
    },
  );
}

Widget arrowBackButton(BuildContext context) {
  return Positioned(
    top: 16,
    left: 16,
    child: IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(
        EvaIcons.arrowBackOutline,
        color: Colors.white,
      ),
    ),
  );
}
