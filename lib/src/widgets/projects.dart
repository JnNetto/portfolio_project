import 'package:flutter/material.dart';
import 'package:portfolio/src/utils/app_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/colors.dart';
import '../utils/custom_carousel_slider.dart';
import 'package:portfolio/src/utils/hover_text.dart';
import 'package:portfolio/src/widgets/project_details.dart';
import 'package:portfolio/src/widgets/projects_coverflow.dart';
import 'package:portfolio/src/widgets/section_heading.dart';

class Projects extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;

  const Projects({super.key, required this.constraints, required this.data});

  @override
  Widget build(BuildContext context) {
    List<Object?> projects = data["projects"];
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeading(
            index: '01',
            eyebrow: 'Projetos',
            title: 'Projetos',
            subtitle: 'Arraste para os lados e toque no card do centro para '
                'ver os detalhes de cada projeto.',
          ),
        ),
        if (projects.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Text("Não há projetos",
                style: AppFonts.aBeeZee(
                    fontSize: constraints.maxWidth > 480 ? 18 : 16,
                    color: ColorsApp.letters(context))),
          )
        else
          ProjectsCoverflow(
            constraints: constraints,
            projects: [
              for (final p in projects) Map<String, dynamic>.from(p as Map),
            ],
          ),
      ],
    );
  }
}

class SliderProjects extends StatefulWidget {
  final BoxConstraints constraints;
  final List projects;

  const SliderProjects({
    super.key,
    required this.constraints,
    required this.projects,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SliderProjectsState createState() => _SliderProjectsState();
}

class _SliderProjectsState extends State<SliderProjects> {
  late CustomCarouselController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CustomCarouselController();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = widget.projects.map((projectMap) {
      final project = Map<String, dynamic>.from(projectMap);
      return ProjectCardWidget(
        constraints: widget.constraints,
        project: project,
      );
    }).toList();

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: widget.constraints.maxWidth > 480
                  ? widget.constraints.maxWidth > 1050
                      ? 250
                      : 100
                  : 0),
          child: widget.projects.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Text("Não há projetos",
                      style: AppFonts.aBeeZee(
                          fontSize: widget.constraints.maxWidth > 480 ? 18 : 16,
                          color: ColorsApp.letters(context))),
                )
              : RepaintBoundary(
                  child: CustomCarouselSlider(
                    items: items,
                    height: 400,
                    enlargeCenterPage: true,
                    autoPlay: false,
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 600),
                    autoPlayCurve: Curves.fastEaseInToSlowEaseOut,
                    viewportFraction:
                        widget.constraints.maxWidth > 480 ? 0.65 : 0.75,
                    controller: _controller,
                  ),
                ),
        ),
        GradientEffectWidget(
            constraints: widget.constraints,
            align: Alignment.centerLeft,
            begin: Alignment.centerRight,
            end: Alignment.centerLeft),
        GradientEffectWidget(
            constraints: widget.constraints,
            align: Alignment.centerRight,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight),
        Positioned(
          left: widget.constraints.maxWidth > 480 ? 100 : 10,
          top: 175,
          child: IconButton(
            hoverColor: ColorsApp.hoverIcon(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                size: widget.constraints.maxWidth > 480 ? 40 : 25,
                color: ColorsApp.letters(context)),
            onPressed: () => _controller.previousPage(),
          ),
        ),
        Positioned(
          right: widget.constraints.maxWidth > 480 ? 100 : 10,
          top: 175,
          child: IconButton(
            hoverColor: ColorsApp.hoverIcon(context),
            icon: Icon(Icons.arrow_forward_ios_rounded,
                size: widget.constraints.maxWidth > 480 ? 40 : 25,
                color: ColorsApp.letters(context)),
            onPressed: () => _controller.nextPage(),
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
                  ColorsApp.background(context).withValues(alpha: 0.09),
                  ColorsApp.background(context).withValues(alpha: 0.19),
                  ColorsApp.background(context).withValues(alpha: 0.29),
                  ColorsApp.background(context).withValues(alpha: 0.39),
                  ColorsApp.background(context).withValues(alpha: 0.49),
                  ColorsApp.background(context).withValues(alpha: 0.59),
                  ColorsApp.background(context).withValues(alpha: 0.69),
                  ColorsApp.background(context).withValues(alpha: 0.79),
                  ColorsApp.background(context).withValues(alpha: 0.89),
                  ColorsApp.background(context).withValues(alpha: 0.99),
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
          color: ColorsApp.card(context),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: ColorsApp.border(context),
            width: constraints.maxWidth > 480 ? 6 : 4,
          ),
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
                          style: AppFonts.aBeeZee(
                              fontSize: 16, color: ColorsApp.letters(context)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: constraints.maxWidth > 480,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    project["state"],
                    style: AppFonts.aBeeZee(
                        fontSize: 25, color: ColorsApp.letters(context)),
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
          style: AppFonts.aBeeZee(
              fontSize:
                  constraints.maxWidth > 480 ? 30 : constraints.maxWidth * .07,
              fontWeight: FontWeight.bold,
              color: ColorsApp.letters(context)),
        ),
        SizedBox(
          height: constraints.maxWidth > 480 ? 15 : 10,
        ),
        Text(
          project["description"],
          textAlign: TextAlign.center,
          style: AppFonts.aBeeZee(
              fontSize: constraints.maxWidth > 480
                  ? 20
                  : constraints.maxWidth * .0385,
              fontWeight: FontWeight.bold,
              color: ColorsApp.letters(context)),
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
          lettersColor: ColorsApp.letterButton(context),
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
      lettersColor: ColorsApp.letterButton(context),
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
      lettersColor: ColorsApp.letterButton(context),
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
      backgroundColor: ColorsApp.backgroundDetails(context),
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
            style: AppFonts.aBeeZee(
                fontSize: constraints.maxWidth > 480 ? 20 : 18,
                color: ColorsApp.letters(context)),
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
              style: AppFonts.aBeeZee(
                  fontSize: constraints.maxWidth > 480 ? 15 : 13,
                  color: ColorsApp.letters(context)),
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
    showProjectDetails(context, project);
  }
}
