import 'dart:collection';
import 'dart:convert';
import 'dart:js';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/colors.dart';

Widget atributes(BoxConstraints constraints,
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
            horizontal: constraints.maxWidth > 1050 ? 200 : 0),
        child: projects.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : CarouselSlider.builder(
                options: CarouselOptions(
                  height: 400,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  aspectRatio: 27 / 9,
                  autoPlayCurve: Curves.easeInExpo,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  viewportFraction: constraints.maxWidth > 1050 ? 0.5 : 0.7,
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
      Positioned(
        left: 10,
        top: 150,
        child: IconButton(
          icon: const Icon(Icons.arrow_back, size: 25, color: Colors.white70),
          onPressed: () => controller.previousPage(),
        ),
      ),
      Positioned(
        right: 10,
        top: 150,
        child: IconButton(
          icon:
              const Icon(Icons.arrow_forward, size: 25, color: Colors.white70),
          onPressed: () => controller.nextPage(),
        ),
      ),
    ],
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
                  texts(constraints, project: project),
                  const SizedBox(height: 10),
                  buttonsToSee(context, constraints, project: project)
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

Widget buttonsToSee(BuildContext context, BoxConstraints constraints,
    {required Map<String, dynamic> project}) {
  return Expanded(
    flex: 1,
    child: Column(
      children: [
        TextButton(
          onPressed: () async {
            await launchUrl(Uri.parse(project["repositoryLink"]));
          },
          child: Text(
            'Ver repositório',
            style: GoogleFonts.aBeeZee(
                fontSize: constraints.maxWidth > 1050 ? 22 : 18,
                color: ColorsApp.letterButton),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {},
          child: Text(
            'Ver aplicação no ar',
            style: GoogleFonts.aBeeZee(
                fontSize: constraints.maxWidth > 1050 ? 22 : 18,
                color: ColorsApp.letterButton),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            // details(context, constraints, project: project);
          },
          child: Text(
            'Ver detalhes',
            style: GoogleFonts.aBeeZee(
                fontSize: constraints.maxWidth > 1050 ? 22 : 18,
                color: ColorsApp.letterButton),
          ),
        ),
      ],
    ),
  );
}

void details(BuildContext context, BoxConstraints constraints,
    {required Map<String, dynamic> project}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      List<String> funcionalidades =
          List<String>.from(project["functionalidades"]);
      List<String> images = List<String>.from(project["images"]);
      return AlertDialog(
        backgroundColor: ColorsApp.card,
        title: Center(
          child: Text("Detalhes",
              style: GoogleFonts.aBeeZee(
                  fontSize: constraints.maxWidth > 1050 ? 22 : 18,
                  color: ColorsApp.letters)),
        ),
        scrollable: true, // Ensure the dialog is scrollable
        content: SizedBox(
          width: constraints.maxWidth * 0.8,
          child: Column(
            children: [
              Flexible(
                // Use Flexible to allow the ListView to expand
                child: ListView.builder(
                  itemCount: funcionalidades.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.check, color: ColorsApp.letters),
                      title: Text(
                        funcionalidades[index],
                        style: GoogleFonts.aBeeZee(
                            fontSize: 16, color: ColorsApp.letters),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Flexible(
                // Use Flexible here as well
                child: ListView.builder(
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Image.memory(
                        base64Decode(images[index]),
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget texts(BoxConstraints constraints,
    {required Map<String, dynamic> project}) {
  return Expanded(
    flex: 1,
    child: Column(
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
    ),
  );
}
