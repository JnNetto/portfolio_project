import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/colors.dart';

Widget attributes(BoxConstraints constraints,
    {required Map<String, dynamic> data}) {
  return Column(
    children: [
      Padding(
        padding: EdgeInsets.only(bottom: constraints.maxWidth > 1050 ? 60 : 40),
        child: Text("|| Habilidades ||",
            style: GoogleFonts.aBeeZee(
                textStyle: TextStyle(
                    fontSize: constraints.maxWidth > 1050 ? 50 : 40,
                    color: ColorsApp.letters))),
      ),
      attributesList(constraints, project: data)
    ],
  );
}

Widget attributesList(BoxConstraints constraints,
    {required Map<String, dynamic> project}) {
  List<Map> habilidades = List<Map>.from(project["attributes"]);
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: habilidades.map((habilidade) {
      return Card(
        color: ColorsApp.card,
        margin: const EdgeInsets.all(10.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Row(
            children: [
              Image.memory(
                base64Decode(habilidade["image"]),
                width: constraints.maxWidth > 1050 ? 150 : 70,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habilidade['title']!,
                        style: TextStyle(
                            fontSize: constraints.maxWidth > 1050 ? 20 : 18,
                            color: ColorsApp.letters)),
                    const SizedBox(height: 5),
                    Text(habilidade['description']!,
                        style: TextStyle(
                            fontSize: constraints.maxWidth > 1050 ? 20 : 18,
                            color: ColorsApp.letters)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList(),
  );
}
