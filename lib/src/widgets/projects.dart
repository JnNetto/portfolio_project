import 'dart:math';
import 'dart:typed_data';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/src/controllers/home_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/colors.dart';
import '../utils/custom_carousel_slider.dart';
import '../utils/grid_menus.dart';
import 'package:portfolio/src/utils/hover_text.dart';

class Projects extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;

  const Projects({super.key, required this.constraints, required this.data});

  @override
  Widget build(BuildContext context) {
    final controller = CustomCarouselController();
    List<Object?> projects = data["projects"];
    return Column(
      children: [
        Padding(
          padding:
              EdgeInsets.only(bottom: constraints.maxWidth > 480 ? 60 : 40),
          child: Text("|| Projetos ||",
              style: GoogleFonts.aBeeZee(
                  textStyle: TextStyle(
                      fontSize: constraints.maxWidth > 480
                          ? 50
                          : constraints.maxWidth * .09,
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
  final CustomCarouselController controller;

  const SliderProjects(
      {super.key,
      required this.constraints,
      required this.projects,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    List<Widget> items = projects.map((projectMap) {
      final project = Map<String, dynamic>.from(projectMap);
      return ProjectCardWidget(
        constraints: constraints,
        project: project,
      );
    }).toList();

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 480
                  ? constraints.maxWidth > 1050
                      ? 250
                      : 100
                  : 0),
          child: projects.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Text("Não há projetos",
                      style: GoogleFonts.aBeeZee(
                          fontSize: constraints.maxWidth > 480 ? 18 : 16,
                          color: Colors.grey)),
                )
              : CustomCarouselSlider(
                  items: items,
                  height: 400,
                  enlargeCenterPage: true,
                  autoPlay: false,
                  autoPlayAnimationDuration: const Duration(milliseconds: 600),
                  autoPlayCurve: Curves.easeIn,
                  viewportFraction: constraints.maxWidth > 480 ? 0.65 : 0.75,
                  controller: controller,
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
          left: constraints.maxWidth > 480 ? 100 : 10,
          top: 175,
          child: IconButton(
            hoverColor: ColorsApp.hoverButton,
            icon: Icon(Icons.arrow_back,
                size: constraints.maxWidth > 480 ? 40 : 25,
                color: Colors.white70),
            onPressed: () => controller.previousPage(),
          ),
        ),
        Positioned(
          right: constraints.maxWidth > 480 ? 100 : 10,
          top: 175,
          child: IconButton(
            hoverColor: ColorsApp.hoverButton,
            icon: Icon(Icons.arrow_forward_outlined,
                size: constraints.maxWidth > 480 ? 40 : 25,
                color: Colors.white70),
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
      visible: constraints.maxWidth > 480,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 480
                ? constraints.maxWidth > 1050
                    ? 248
                    : 98
                : 0),
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
          minWidth: constraints.maxWidth > 480 ? 500 : 250,
          maxWidth: constraints.maxWidth > 480 ? 500 : 250),
      child: Container(
        decoration: BoxDecoration(
          color: ColorsApp.card,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: ColorsApp.shadowColor,
            width: constraints.maxWidth > 480 ? 6 : 4,
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
                      visible: constraints.maxWidth <= 480,
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
                visible: constraints.maxWidth > 480,
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
          textAlign: TextAlign.center,
          style: GoogleFonts.aBeeZee(
              fontSize:
                  constraints.maxWidth > 480 ? 30 : constraints.maxWidth * .07,
              fontWeight: FontWeight.bold,
              color: ColorsApp.letters),
        ),
        SizedBox(
          height: constraints.maxWidth > 480 ? 15 : 10,
        ),
        Text(
          project["description"],
          textAlign: TextAlign.center,
          style: GoogleFonts.aBeeZee(
              fontSize:
                  constraints.maxWidth > 480 ? 20 : constraints.maxWidth * .035,
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
        SizedBox(height: constraints.maxWidth > 480 ? 7.5 : 0),
        DeployedApplicationWidget(constraints: constraints, project: project),
        SizedBox(height: constraints.maxWidth > 480 ? 7.5 : 0),
        HoverText(
          text: "Ver detalhes",
          onPressed: () {
            DetailsWidget.details(context,
                constraints: constraints, project: project);
          },
          lettersColor: ColorsApp.letterButton,
          fontSize: constraints.maxWidth > 480
              ? constraints.maxWidth > 1050
                  ? 20
                  : constraints.maxWidth * .02
              : constraints.maxWidth * .04,
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
        final Uri url = Uri.parse(project["repositoryLink"]);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      lettersColor: ColorsApp.letterButton,
      fontSize: constraints.maxWidth > 480
          ? constraints.maxWidth > 1050
              ? 20
              : constraints.maxWidth * .02
          : constraints.maxWidth * .04,
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
      text: "Ver aplicação no ar",
      onPressed: () async {
        if (project["link"] != "") {
          final Uri url = Uri.parse(project["link"]);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialog(
                constraints: constraints,
              );
            },
          );
        }
      },
      lettersColor: ColorsApp.letterButton,
      fontSize: constraints.maxWidth > 480
          ? constraints.maxWidth > 1050
              ? 20
              : constraints.maxWidth * .02
          : constraints.maxWidth * .04,
    );
  }
}

class CustomDialog extends StatelessWidget {
  final BoxConstraints constraints;
  const CustomDialog({super.key, required this.constraints});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorsApp.backgroundDetails,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/construction.png',
            height: constraints.maxWidth > 480 ? 300 : 200,
            width: constraints.maxWidth > 480 ? 300 : 200,
          ),
          const SizedBox(height: 10),
          Text(
            'Estamos trabalhando nisso',
            style: GoogleFonts.aBeeZee(
                fontSize: constraints.maxWidth > 480 ? 20 : 18,
                color: ColorsApp.letters),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: <Widget>[
        Align(
          alignment: Alignment.bottomRight,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Fechar',
              style: GoogleFonts.aBeeZee(
                  fontSize: constraints.maxWidth > 480 ? 15 : 13,
                  color: ColorsApp.letters),
            ),
          ),
        ),
      ],
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
    final HomeController controller = HomeController();
    List<String> funcionalidades =
        List<String>.from(project["functionalities"]);
    String plataforma = project["platform"];
    String minhaFuncao = project["myFunction"];
    List<String> tecnologias = List<String>.from(project["technologiesUsed"]);

    return Stack(
      children: [
        AlertDialog(
          backgroundColor: ColorsApp.backgroundDetails,
          title: Center(
            child: Text("Detalhes",
                style: GoogleFonts.aBeeZee(
                    fontSize: constraints.maxWidth > 480 ? 32 : 26,
                    color: ColorsApp.letters)),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: constraints.maxWidth > 480 ? 30 : 15),
                if (constraints.maxWidth > 480)
                  WebDetails(
                      constraints: constraints,
                      technologiesUsed: technologiesUsed(tecnologias),
                      plataforma: plataforma,
                      minhaFuncao: minhaFuncao),
                if (constraints.maxWidth <= 480)
                  MobileDetails(
                      constraints: constraints,
                      technologiesUsed: technologiesUsed(tecnologias),
                      plataforma: plataforma,
                      minhaFuncao: minhaFuncao),
                SizedBox(height: constraints.maxWidth > 480 ? 30 : 20),
                Text("Funcionalidades do projeto",
                    style: GoogleFonts.aBeeZee(
                        fontSize: constraints.maxWidth > 480
                            ? 24
                            : constraints.maxWidth * .05,
                        color: ColorsApp.letters)),
                Funtionalities(funcionalidades: funcionalidades),
                const SizedBox(
                  height: 30,
                ),
                Text("Imagens do projeto",
                    style: GoogleFonts.aBeeZee(
                        fontSize: constraints.maxWidth > 480 ? 24 : 23,
                        color: ColorsApp.letters)),
                FutureBuilder<List<Uint8List>>(
                  future: controller.fetchImages(project["name"]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 50),
                        child: CircularProgressIndicator(),
                      ));
                    } else if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Text("Erro ao carregar imagens",
                            style: GoogleFonts.aBeeZee(
                                fontSize: constraints.maxWidth > 480 ? 18 : 16,
                                color: Colors.red)),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Text("Nenhuma imagem disponível",
                            style: GoogleFonts.aBeeZee(
                                fontSize: constraints.maxWidth > 480 ? 18 : 16,
                                color: Colors.grey)),
                      );
                    } else {
                      return Images(
                        images: snapshot.data!,
                        plataforma: plataforma,
                        context: context,
                        constraints: constraints,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        ArrowBackButton(context: context),
      ],
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
}

class MobileDetails extends StatelessWidget {
  final BoxConstraints constraints;
  final Widget technologiesUsed;
  final String plataforma;
  final String minhaFuncao;

  const MobileDetails(
      {super.key,
      required this.constraints,
      required this.technologiesUsed,
      required this.plataforma,
      required this.minhaFuncao});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Tipo de plataforma:",
            textAlign: TextAlign.left,
            style: GoogleFonts.aBeeZee(
                fontSize: constraints.maxWidth > 480 ? 20 : 18,
                color: ColorsApp.letters)),
        Text(plataforma,
            textAlign: TextAlign.left,
            style: GoogleFonts.aBeeZee(
                fontSize: constraints.maxWidth > 480 ? 20 : 18,
                color: ColorsApp.letters)),
        const SizedBox(
          height: 20,
        ),
        Text("Função desempenhada:",
            textAlign: TextAlign.left,
            style: GoogleFonts.aBeeZee(
                fontSize: constraints.maxWidth > 480 ? 20 : 18,
                color: ColorsApp.letters)),
        Text(minhaFuncao,
            textAlign: TextAlign.left,
            style: GoogleFonts.aBeeZee(
                fontSize: constraints.maxWidth > 480 ? 20 : 18,
                color: ColorsApp.letters)),
        const SizedBox(
          height: 20,
        ),
        Text("Tecnologias usadas:",
            textAlign: TextAlign.left,
            style: GoogleFonts.aBeeZee(
                fontSize: constraints.maxWidth > 480 ? 24 : 23,
                color: ColorsApp.letters)),
        technologiesUsed,
      ],
    );
  }
}

class WebDetails extends StatelessWidget {
  final BoxConstraints constraints;
  final Widget technologiesUsed;
  final String plataforma;
  final String minhaFuncao;

  const WebDetails(
      {super.key,
      required this.constraints,
      required this.technologiesUsed,
      required this.plataforma,
      required this.minhaFuncao});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Text("Tipo de plataforma:",
                textAlign: TextAlign.left,
                style: GoogleFonts.aBeeZee(
                    fontSize: constraints.maxWidth > 480 ? 20 : 18,
                    color: ColorsApp.letters)),
            Text(plataforma,
                textAlign: TextAlign.left,
                style: GoogleFonts.aBeeZee(
                    fontSize: constraints.maxWidth > 480 ? 20 : 18,
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
                    fontSize: constraints.maxWidth > 480 ? 20 : 18,
                    color: ColorsApp.letters)),
            Text(minhaFuncao,
                textAlign: TextAlign.left,
                style: GoogleFonts.aBeeZee(
                    fontSize: constraints.maxWidth > 480 ? 20 : 18,
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
                    fontSize: constraints.maxWidth > 480 ? 24 : 23,
                    color: ColorsApp.letters)),
            technologiesUsed,
          ],
        ),
      ],
    );
  }
}

class Images extends StatelessWidget {
  final BoxConstraints constraints;
  final List<Uint8List> images;
  final String plataforma;
  final BuildContext context;

  const Images(
      {super.key,
      required this.constraints,
      required this.images,
      required this.plataforma,
      required this.context});

  @override
  Widget build(BuildContext context) {
    dynamic zoom(
      BuildContext context,
      Uint8List image,
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
                    image,
                    fit: BoxFit.contain,
                  ),
                ),
                ArrowBackButton(context: context)
              ],
            ),
          );
        },
      );
    }

    int halfLength = images.length <= 3 ? 3 : (images.length / 2).ceil();
    late double? width;
    if (plataforma == "Mobile") {
      if (constraints.maxWidth > 480) {
        width = 150;
      } else {
        width = 70;
      }
    } else {
      if (constraints.maxWidth > 480) {
        width = 350;
      } else {
        width = 250;
      }
    }
    return GridMenus(
      contentLine1: images.take(halfLength).map((image) {
        return GestureDetector(
          onTap: () {
            zoom(context, image);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.memory(
              image,
              width: width,
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
      contentLine2: images.skip(halfLength).map((image) {
        return GestureDetector(
          onTap: () {
            zoom(context, image);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.memory(image, width: width),
          ),
        );
      }).toList(),
    );
  }
}

class Funtionalities extends StatelessWidget {
  const Funtionalities({
    super.key,
    required this.funcionalidades,
  });

  final List<String> funcionalidades;

  @override
  Widget build(BuildContext context) {
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
}

class ArrowBackButton extends StatelessWidget {
  final BuildContext context;

  const ArrowBackButton({super.key, required this.context});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: IconButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(ColorsApp.card),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          shadowColor: WidgetStateProperty.all(ColorsApp.shadowColor),
          elevation: WidgetStateProperty.all(10),
        ),
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
