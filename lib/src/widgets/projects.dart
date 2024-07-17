import 'dart:convert';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart' as carousel_slider;
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/colors.dart';
import '../utils/grid_menus.dart';
import 'package:portfolio/src/utils/hover_text.dart';

class Projects extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;

  const Projects({super.key, required this.constraints, required this.data});

  @override
  Widget build(BuildContext context) {
    final carousel_slider.CarouselController controller =
        carousel_slider.CarouselController();
    List<Object?> projects = data["projects"];
    return Column(
      children: [
        Padding(
          padding:
              EdgeInsets.only(bottom: constraints.maxWidth > 1050 ? 60 : 40),
          child: Text("|| Projetos ||",
              style: GoogleFonts.aBeeZee(
                  textStyle: TextStyle(
                      fontSize: constraints.maxWidth > 1050 ? 50 : 40,
                      color: ColorsApp.letters))),
        ),
        SliderProjects(
            constraints: constraints,
            projects: projects,
            controller: controller),
      ],
    );
  }
}

class SliderProjects extends StatelessWidget {
  final BoxConstraints constraints;
  final List projects;
  final carousel_slider.CarouselController controller;

  const SliderProjects(
      {super.key,
      required this.constraints,
      required this.projects,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 1050 ? 250 : 0),
          child: projects.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : carousel_slider.CarouselSlider.builder(
                  options: carousel_slider.CarouselOptions(
                    height: 400,
                    enlargeCenterPage: true,
                    autoPlay: false,
                    aspectRatio: 16 / 9,
                    autoPlayCurve: Curves.easeInExpo,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    viewportFraction: constraints.maxWidth > 1050 ? 0.4 : 0.7,
                  ),
                  carouselController: controller,
                  itemCount: projects.length,
                  itemBuilder: (context, index, realIdx) {
                    final project = Map<String, dynamic>.from(
                        projects[index] as Map); // Evita conversão dupla
                    return ProjectCardWidget(
                        constraints: constraints, project: project);
                  },
                ),
        ),
        GradientEffectWidget(
            constraints: constraints,
            align: Alignment.centerLeft,
            begin: Alignment.centerRight,
            end: Alignment.centerLeft),
        GradientEffectWidget(
            constraints: constraints,
            align: Alignment.centerRight,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight),
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
            icon: const Icon(Icons.arrow_forward,
                size: 25, color: Colors.white70),
            onPressed: () => controller.nextPage(),
          ),
        ),
      ],
    );
  }
}

class GradientEffectWidget extends StatelessWidget {
  final BoxConstraints constraints;
  final Alignment align, begin, end;

  const GradientEffectWidget(
      {super.key,
      required this.constraints,
      required this.align,
      required this.begin,
      required this.end});

  @override
  Widget build(BuildContext context) {
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
}

class ProjectCardWidget extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> project;

  const ProjectCardWidget(
      {super.key, required this.constraints, required this.project});

  @override
  Widget build(BuildContext context) {
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
                            child: TextsWidget(
                                constraints: constraints, project: project))),
                    Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                            child: ButtonsToSeeWidget(
                                constraints: constraints, project: project))),
                    Visibility(
                      visible: constraints.maxWidth <= 1050,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          project["state"],
                          style: GoogleFonts.aBeeZee(
                              fontSize: 22, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: constraints.maxWidth > 1050,
                child: Positioned(
                  bottom: 10,
                  left: 10,
                  child: Text(
                    project["state"],
                    style:
                        GoogleFonts.aBeeZee(fontSize: 22, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TextsWidget extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> project;

  const TextsWidget(
      {super.key, required this.constraints, required this.project});

  @override
  Widget build(BuildContext context) {
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
}

class ButtonsToSeeWidget extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> project;

  const ButtonsToSeeWidget(
      {super.key, required this.constraints, required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RepositoryLinkWidget(constraints: constraints, project: project),
        SizedBox(height: constraints.maxWidth > 1050 ? 7.5 : 0),
        DeployedApplicationWidget(constraints: constraints, project: project),
        SizedBox(height: constraints.maxWidth > 1050 ? 7.5 : 0),
        HoverText(
          text: "Ver detalhes",
          onPressed: () {
            DetailsWidget.details(context,
                constraints: constraints, project: project);
          },
          lettersColor: ColorsApp.letterButton,
          fontSize: constraints.maxWidth > 1050 ? 20 : 16,
        )
      ],
    );
  }
}

class RepositoryLinkWidget extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> project;

  const RepositoryLinkWidget(
      {super.key, required this.constraints, required this.project});

  @override
  Widget build(BuildContext context) {
    return HoverText(
      text: "Ver Repositório",
      onPressed: () async {
        final Uri url = Uri.parse(project["urlGitHub"]);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      lettersColor: ColorsApp.letterButton,
      fontSize: constraints.maxWidth > 1050 ? 20 : 16,
    );
  }
}

class DeployedApplicationWidget extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> project;

  const DeployedApplicationWidget(
      {super.key, required this.constraints, required this.project});

  @override
  Widget build(BuildContext context) {
    return HoverText(
      text: "Ver aplicação em produção",
      onPressed: () async {
        final Uri url = Uri.parse(project["urlRepository"]);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      lettersColor: ColorsApp.letterButton,
      fontSize: constraints.maxWidth > 1050 ? 20 : 16,
    );
  }
}

class DetailsWidget {
  static void details(BuildContext context,
      {required BoxConstraints constraints,
      required Map<String, dynamic> project}) {
    showDialog(
      context: context,
      builder: (context) {
        return DetailsDialog(constraints: constraints, project: project);
      },
    );
  }
}

class DetailsDialog extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> project;

  const DetailsDialog(
      {super.key, required this.constraints, required this.project});

  @override
  Widget build(BuildContext context) {
    List<String> funcionalidades =
        List<String>.from(project["functionalities"]);
    List<String> imagens = List<String>.from(project["images"]);
    String plataforma = project["platform"];
    String minhaFuncao = project["myFunction"];
    List<String> tecnologias = List<String>.from(project["technologiesUsed"]);
    return Stack(
      children: [
        arrowBackButton(context),
        AlertDialog(
          backgroundColor: ColorsApp.backgroundDetails,
          title: Center(
            child: Text("Detalhes",
                style: GoogleFonts.aBeeZee(
                    fontSize: constraints.maxWidth > 1050 ? 32 : 26,
                    color: ColorsApp.letters)),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Visibility(
                  visible: constraints.maxWidth > 1050,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text("Tipo de plataforma:",
                              textAlign: TextAlign.left,
                              style: GoogleFonts.aBeeZee(
                                  fontSize:
                                      constraints.maxWidth > 1050 ? 20 : 18,
                                  color: ColorsApp.letters)),
                          Text(plataforma,
                              textAlign: TextAlign.left,
                              style: GoogleFonts.aBeeZee(
                                  fontSize:
                                      constraints.maxWidth > 1050 ? 20 : 18,
                                  color: ColorsApp.letters)),
                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        children: [
                          Text("Função desempenhada:",
                              textAlign: TextAlign.left,
                              style: GoogleFonts.aBeeZee(
                                  fontSize:
                                      constraints.maxWidth > 1050 ? 20 : 18,
                                  color: ColorsApp.letters)),
                          Text(minhaFuncao,
                              textAlign: TextAlign.left,
                              style: GoogleFonts.aBeeZee(
                                  fontSize:
                                      constraints.maxWidth > 1050 ? 20 : 18,
                                  color: ColorsApp.letters)),
                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        children: [
                          Text("Tecnologias usadas:",
                              textAlign: TextAlign.left,
                              style: GoogleFonts.aBeeZee(
                                  fontSize:
                                      constraints.maxWidth > 1050 ? 24 : 23,
                                  color: ColorsApp.letters)),
                          technologiesUsed(tecnologias),
                        ],
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: constraints.maxWidth <= 1050,
                  child: Text("Tipo de plataforma: $plataforma",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.aBeeZee(
                          fontSize: constraints.maxWidth > 1050 ? 20 : 18,
                          color: ColorsApp.letters)),
                ),
                Visibility(
                  visible: constraints.maxWidth <= 1050,
                  child: const SizedBox(
                    height: 20,
                  ),
                ),
                Visibility(
                  visible: constraints.maxWidth <= 1050,
                  child: Text("Função desempenhada: $minhaFuncao",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.aBeeZee(
                          fontSize: constraints.maxWidth > 1050 ? 20 : 18,
                          color: ColorsApp.letters)),
                ),
                Visibility(
                  visible: constraints.maxWidth <= 1050,
                  child: const SizedBox(
                    height: 20,
                  ),
                ),
                Visibility(
                  visible: constraints.maxWidth <= 1050,
                  child: Text("Tecnologias usadas:",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.aBeeZee(
                          fontSize: constraints.maxWidth > 1050 ? 24 : 23,
                          color: ColorsApp.letters)),
                ),
                Visibility(
                    visible: constraints.maxWidth <= 1050,
                    child: technologiesUsed(tecnologias)),
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

  Widget technologiesUsed(List<String> tecnologias) {
    Color getRandomColor() {
      Random random = Random();
      Color color;
      do {
        color = Color.fromRGBO(
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
          1.0,
        );
      } while (color == Colors.white);
      return color;
    }

    Set<Color> usedColors = {};

    Color getUniqueRandomColor() {
      Color color;
      do {
        color = getRandomColor();
      } while (usedColors.contains(color));
      usedColors.add(color);
      return color;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: tecnologias.map((tech) {
        Color bgColor = getUniqueRandomColor();
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          decoration: BoxDecoration(
              color: bgColor, borderRadius: BorderRadius.circular(8)),
          child: Text(
            tech,
            style: const TextStyle(
              color: Colors.white,
            ),
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
}
