import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/colors.dart';

class Attributes extends StatefulWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;

  const Attributes({
    super.key,
    required this.constraints,
    required this.data,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AttributesState createState() => _AttributesState();
}

class _AttributesState extends State<Attributes> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    double maxHeightEffect = widget.constraints.maxWidth > 1050 ? 300 : 170;
    double maxSizeCard = widget.constraints.maxWidth > 1050 ? 180 : 100;
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          title(),
          listViewAtributtes(widget.constraints, widget.data, _isExpanded,
              maxHeightEffect, maxSizeCard),
        ],
      ),
    );
  }

  Widget attributesList(BoxConstraints constraints,
      {required Map<String, dynamic> project}) {
    List<Map> habilidades = List<Map>.from(project["attributes"]);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: habilidades.map((habilidade) {
        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 1050 ? 200 : 50),
          child: Card(
            color: ColorsApp.card,
            margin: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              children: [
                image(habilidade, constraints),
                const SizedBox(width: 10),
                texts(habilidade, constraints)
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget title() {
    return Padding(
      padding:
          EdgeInsets.only(bottom: widget.constraints.maxWidth > 1050 ? 60 : 40),
      child: Text("|| Habilidades ||",
          style: GoogleFonts.aBeeZee(
              textStyle: TextStyle(
                  fontSize: widget.constraints.maxWidth > 1050 ? 50 : 40,
                  color: ColorsApp.letters))),
    );
  }

  Widget listViewAtributtes(
      BoxConstraints constraints,
      Map<String, dynamic> data,
      bool isExpanded,
      double maxHeightEffect,
      double maxSizeCard) {
    return Container(
      constraints: _isExpanded
          ? BoxConstraints(
              maxHeight: widget.constraints.maxWidth > 1050
                  ? widget.data["attributes"].length * 180
                  : widget.data["attributes"].length * 100,
            )
          : BoxConstraints(
              maxHeight: maxHeightEffect,
            ),
      child: Stack(
        children: [
          listView(constraints, data),
          showLessButton(constraints, isExpanded),
          gradientEffect(
              constraints, data, isExpanded, maxHeightEffect, maxSizeCard),
          showMoreButton(
              constraints, data, isExpanded, maxHeightEffect, maxSizeCard),
        ],
      ),
    );
  }

  listView(BoxConstraints constraints, Map<String, dynamic> data) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: attributesList(widget.constraints, project: widget.data),
    );
  }

  showLessButton(BoxConstraints constraints, bool isExpanded) {
    return Visibility(
      visible: _isExpanded,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ElevatedButton(
          style: ButtonStyle(
            fixedSize: MaterialStateProperty.all<Size>(Size(
                widget.constraints.maxWidth > 1050 ? 150 : 130,
                widget.constraints.maxWidth > 1050 ? 35 : 18)),
            backgroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
                side: BorderSide(color: ColorsApp.color4, width: 2.0),
              ),
            ),
            elevation: MaterialStateProperty.all<double>(0),
          ),
          onPressed: () {
            setState(() {
              _isExpanded = false;
            });
          },
          child: const Text(
            "Exibir menos",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget gradientEffect(BoxConstraints constraints, Map<String, dynamic> data,
      bool isExpanded, double maxHeightEffect, double maxSizeCard) {
    return Visibility(
      visible: !_isExpanded &&
          widget.data["attributes"].length * maxSizeCard > maxHeightEffect,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: widget.constraints.maxWidth > 1050 ? 200 : 50),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
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

  Widget showMoreButton(BoxConstraints constraints, Map<String, dynamic> data,
      bool isExpanded, double maxHeightEffect, double maxSizeCard) {
    return Visibility(
      visible: !_isExpanded &&
          widget.data["attributes"].length * maxSizeCard > maxHeightEffect,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ElevatedButton(
          style: ButtonStyle(
            fixedSize: MaterialStateProperty.all<Size>(Size(
                widget.constraints.maxWidth > 1050 ? 150 : 130,
                widget.constraints.maxWidth > 1050 ? 35 : 18)),
            backgroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
                side: BorderSide(color: ColorsApp.color4, width: 2.0),
              ),
            ),
            elevation: MaterialStateProperty.all<double>(0),
          ),
          onPressed: () {
            setState(() {
              _isExpanded = true;
            });
          },
          child: const Text(
            "Exibir mais",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  image(Map habilidade, BoxConstraints constraints) {
    return Image.memory(
      base64Decode(habilidade["image"]),
      width: constraints.maxWidth > 1050 ? 150 : 70,
      fit: BoxFit.cover,
    );
  }

  Widget texts(Map habilidade, BoxConstraints constraints) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(habilidade['title']!,
              style: TextStyle(
                  fontSize: constraints.maxWidth > 1050 ? 22 : 20,
                  color: ColorsApp.letters)),
          const SizedBox(height: 5),
          Text(habilidade['description']!,
              style: TextStyle(
                  fontSize: constraints.maxWidth > 1050 ? 16 : 14,
                  color: ColorsApp.letters)),
        ],
      ),
    );
  }
}
